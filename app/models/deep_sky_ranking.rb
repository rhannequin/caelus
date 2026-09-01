# frozen_string_literal: true

class DeepSkyRanking
  MINIMUM_ALTITUDE = Astronoby::Angle.from_degrees(15)
  SUSTAINED_ALTITUDE = Astronoby::Angle.from_degrees(30)
  REFERENCE_ALTITUDE = Astronoby::Angle.from_degrees(60)
  MOONLIT_ALTITUDE = Astronoby::Angle.from_degrees(10)
  MOON_SEPARATION_REACH = Astronoby::Angle.from_degrees(90)

  EASE_WEIGHTS = {
    naked_eye: 1.0,
    binoculars: 0.8,
    small_telescope: 0.5,
    large_telescope: 0.2
  }.freeze

  NOTABILITY_WEIGHTS = {
    showpiece: 1.0,
    notable: 0.72,
    ordinary: 0.45,
    faint: 0.22
  }.freeze

  MOONLIGHT_SENSITIVITY = {
    spiral_galaxy: 1.0,
    irregular_galaxy: 1.0,
    elliptical_galaxy: 1.0,
    lenticular_galaxy: 1.0,
    supernova_remnant: 0.9,
    nebula: 0.85,
    nebula_with_cluster: 0.85,
    reflection_nebula: 0.85,
    star_cloud: 0.6,
    globular_cluster: 0.4,
    planetary_nebula: 0.35,
    open_cluster: 0.25,
    asterism: 0.2,
    double_star: 0.15
  }.freeze
  DEFAULT_MOONLIGHT_SENSITIVITY = 0.5

  FAMILIES = {
    spiral_galaxy: :galaxy,
    elliptical_galaxy: :galaxy,
    irregular_galaxy: :galaxy,
    lenticular_galaxy: :galaxy,
    nebula: :nebula,
    nebula_with_cluster: :nebula,
    reflection_nebula: :nebula,
    planetary_nebula: :nebula,
    supernova_remnant: :nebula,
    globular_cluster: :cluster,
    open_cluster: :cluster,
    star_cloud: :other,
    asterism: :other,
    double_star: :other
  }.freeze
  MAXIMUM_FAMILY_SHARE = 0.5
  ANCHOR_COUNT = 2
  ROTATION_POOL_SIZE = 24

  ALTITUDE_WEIGHT = 0.34
  SUSTAINED_WEIGHT = 0.14
  EASE_WEIGHT = 0.16
  NOTABILITY_WEIGHT = 0.36
  MOONLIGHT_WEIGHT = 0.55

  Placement = Data.define(
    :deep_sky_object,
    :score,
    :highest_altitude,
    :highest_altitude_time
  )

  def initialize(night:, deep_sky_objects: DeepSkyObjectsCatalog.all)
    @night = night
    @deep_sky_objects = deep_sky_objects
  end

  def self.maximum_per_family(limit)
    (limit * MAXIMUM_FAMILY_SHARE).ceil
  end

  def best(limit)
    counts = Hash.new(0)
    selection = []
    cap = self.class.maximum_per_family(limit)

    add_within_cap(anchors(limit), selection, counts, limit, cap)
    add_within_cap(rotating_pool(selection), selection, counts, limit, cap)
    add_within_cap(placements, selection, counts, limit, cap)
    selection.concat((placements - selection).first(limit - selection.size))

    selection
  end

  def placements
    @placements ||= @deep_sky_objects
      .filter_map { |deep_sky_object| place(deep_sky_object) }
      .sort_by { |placement| -placement.score }
  end

  private

  def anchors(limit)
    placements.first([ANCHOR_COUNT, limit].min)
  end

  def rotating_pool(selection)
    pool = (placements - selection).first(ROTATION_POOL_SIZE)
    return pool if pool.empty?

    pool.rotate(@night.date.yday % pool.size)
  end

  def add_within_cap(candidates, selection, counts, limit, cap)
    candidates.each do |placement|
      break if selection.size == limit
      next if selection.include?(placement)

      family = family_of(placement.deep_sky_object)
      next if counts[family] >= cap

      counts[family] += 1
      selection << placement
    end
  end

  def family_of(deep_sky_object)
    FAMILIES.fetch(deep_sky_object.type, :other)
  end

  def place(deep_sky_object)
    return unless @night.dark?

    positions = @night.track(deep_sky_object.astronoby_deep_sky_object)
    altitudes = positions.map { |position| position.horizontal.altitude }
    highest = altitudes.max
    return if highest < MINIMUM_ALTITUDE

    Placement.new(
      deep_sky_object: deep_sky_object,
      score: score(deep_sky_object, positions, altitudes, highest),
      highest_altitude: highest,
      highest_altitude_time: @night.times[altitudes.index(highest)]
    )
  end

  def score(deep_sky_object, positions, altitudes, highest)
    ALTITUDE_WEIGHT * altitude_term(highest) +
      SUSTAINED_WEIGHT * sustained_term(altitudes) +
      EASE_WEIGHT * ease_term(deep_sky_object) +
      NOTABILITY_WEIGHT * notability_term(deep_sky_object) -
      MOONLIGHT_WEIGHT * moonlight_penalty(deep_sky_object, positions, altitudes)
  end

  def altitude_term(highest)
    clamp(highest.degrees / REFERENCE_ALTITUDE.degrees)
  end

  def sustained_term(altitudes)
    sustained = altitudes.count { |altitude| altitude >= SUSTAINED_ALTITUDE }

    sustained / altitudes.size.to_f
  end

  def ease_term(deep_sky_object)
    EASE_WEIGHTS.fetch(deep_sky_object.instrument, 0.5)
  end

  def notability_term(deep_sky_object)
    NOTABILITY_WEIGHTS.fetch(deep_sky_object.notability, 0.0)
  end

  def moonlight_penalty(deep_sky_object, positions, altitudes)
    sensitivity = MOONLIGHT_SENSITIVITY.fetch(
      deep_sky_object.type,
      DEFAULT_MOONLIGHT_SENSITIVITY
    )

    sensitivity * average_glare(positions, altitudes)
  end

  def average_glare(positions, altitudes)
    glare = positions.each_index.sum do |index|
      moon = @night.moon_positions[index]
      next 0.0 if altitudes[index] < MOONLIT_ALTITUDE
      next 0.0 unless moon.altitude.positive?

      moon.illuminated_fraction**2 * proximity(positions[index], moon)
    end

    glare / positions.size
  end

  def proximity(position, moon)
    separation = AngularSeparation.between(
      position.equatorial,
      moon.equatorial
    )
    nearness = clamp(
      (MOON_SEPARATION_REACH.degrees - separation.degrees) /
        MOON_SEPARATION_REACH.degrees
    )

    0.35 + 0.65 * nearness
  end

  def clamp(value)
    value.clamp(0.0, 1.0)
  end
end
