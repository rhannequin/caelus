# frozen_string_literal: true

class DeepSkyRanking
  MINIMUM_ALTITUDE = Astronoby::Angle.from_degrees(15)
  SUSTAINED_ALTITUDE = Astronoby::Angle.from_degrees(30)
  REFERENCE_ALTITUDE = Astronoby::Angle.from_degrees(60)
  MOONLIT_ALTITUDE = Astronoby::Angle.from_degrees(10)
  MOON_SEPARATION_REACH = Astronoby::Angle.from_degrees(90)

  FAINTEST_MAGNITUDE = 11.0

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
  MAXIMUM_PER_FAMILY = 3

  ALTITUDE_WEIGHT = 0.34
  SUSTAINED_WEIGHT = 0.14
  BRIGHTNESS_WEIGHT = 0.16
  NOTABILITY_WEIGHT = 0.36
  MOONLIGHT_WEIGHT = 0.55

  Placement = Data.define(
    :messier_object,
    :score,
    :highest_altitude,
    :highest_altitude_time
  )

  def initialize(night:, messier_objects: MessierCatalog.all)
    @night = night
    @messier_objects = messier_objects
  end

  def best(limit)
    varied = varied_selection(limit)

    varied + (placements - varied).first(limit - varied.size)
  end

  def placements
    @placements ||= @messier_objects
      .filter_map { |messier_object| place(messier_object) }
      .sort_by { |placement| -placement.score }
  end

  private

  def varied_selection(limit)
    counts = Hash.new(0)

    placements.each_with_object([]) do |placement, selection|
      return selection if selection.size == limit

      family = family_of(placement.messier_object)
      next if counts[family] >= MAXIMUM_PER_FAMILY

      counts[family] += 1
      selection << placement
    end
  end

  def family_of(messier_object)
    FAMILIES.fetch(messier_object.type, :other)
  end

  def place(messier_object)
    return unless @night.dark?

    positions = @night.track(messier_object.deep_sky_object)
    altitudes = positions.map { |position| position.horizontal.altitude }
    highest = altitudes.max
    return if highest < MINIMUM_ALTITUDE

    Placement.new(
      messier_object: messier_object,
      score: score(messier_object, positions, altitudes, highest),
      highest_altitude: highest,
      highest_altitude_time: @night.times[altitudes.index(highest)]
    )
  end

  def score(messier_object, positions, altitudes, highest)
    ALTITUDE_WEIGHT * altitude_term(highest) +
      SUSTAINED_WEIGHT * sustained_term(altitudes) +
      BRIGHTNESS_WEIGHT * brightness_term(messier_object) +
      NOTABILITY_WEIGHT * notability_term(messier_object) -
      MOONLIGHT_WEIGHT * moonlight_penalty(messier_object, positions, altitudes)
  end

  def altitude_term(highest)
    clamp(highest.degrees / REFERENCE_ALTITUDE.degrees)
  end

  def sustained_term(altitudes)
    sustained = altitudes.count { |altitude| altitude >= SUSTAINED_ALTITUDE }

    sustained / altitudes.size.to_f
  end

  def brightness_term(messier_object)
    brightest = @messier_objects.map(&:magnitude).min
    span = FAINTEST_MAGNITUDE - brightest
    return 0.0 if span.zero?

    clamp((FAINTEST_MAGNITUDE - messier_object.magnitude) / span)
  end

  def notability_term(messier_object)
    NOTABILITY_WEIGHTS.fetch(messier_object.notability, 0.0)
  end

  def moonlight_penalty(messier_object, positions, altitudes)
    sensitivity = MOONLIGHT_SENSITIVITY.fetch(
      messier_object.type,
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
