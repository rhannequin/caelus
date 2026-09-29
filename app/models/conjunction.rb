# frozen_string_literal: true

class Conjunction
  KINDS = [
    CelestialEvent::MOON_PLANET_CONJUNCTION,
    CelestialEvent::PLANETARY_CONJUNCTION
  ].freeze

  MOON_NIGHTS_AROUND_PEAK = 1
  PLANETARY_NIGHTS_AROUND_PEAK = 3
  STILL_PAIRED_MARGIN = Astronoby::Angle.from_degrees(5)
  DAYTIME_ELONGATION = Astronoby::Angle.from_degrees(45)

  UNOBSERVABLE_REASONS = [
    NO_DARKNESS = :no_darkness,
    DRIFTED = :drifted,
    BELOW_HORIZON = :below_horizon
  ].freeze

  Sighting = Data.define(:date, :time, :altitude, :azimuth, :separation)

  attr_reader :celestial_event

  def initialize(celestial_event:, observer:)
    @celestial_event = celestial_event
    @observer = observer
  end

  def peak_at
    @peak_at ||= @celestial_event.peak_at.in_time_zone
  end

  def date
    peak_at.to_date
  end

  def moon?
    @celestial_event.kind == CelestialEvent::MOON_PLANET_CONJUNCTION
  end

  def known_bodies?
    primary_class.present? && secondary_class.present?
  end

  def near_the_sun?
    solar_elongation < DAYTIME_ELONGATION
  end

  def primary
    @primary ||= primary_class.new(observer: @observer, time: peak_at)
  end

  def secondary
    @secondary ||= secondary_class.new(observer: @observer, time: peak_at)
  end

  def bodies
    [primary, secondary]
  end

  def separation
    @separation ||= primary.apparent.separation_from(secondary.apparent)
  end

  def apparent_separation
    @apparent_separation ||=
      primary.topocentric.separation_from(secondary.topocentric)
  end

  def solar_elongation
    @solar_elongation ||= bodies.map(&:elongation).min_by(&:degrees)
  end

  def position_angle
    @position_angle ||= position_angle_between(
      primary.apparent.equatorial,
      secondary.apparent.equatorial
    )
  end

  def observed_pair
    return unless closest_apparition

    @observed_pair ||= bodies_at(closest_apparition.time)
  end

  def observed_separation
    return separation unless observed_pair

    observed_pair.first.topocentric.separation_from(
      observed_pair.second.topocentric
    )
  end

  def observed_position_angle
    return position_angle unless observed_pair

    position_angle_between(
      observed_pair.first.topocentric.equatorial,
      observed_pair.second.topocentric.equatorial
    )
  end

  def parallactic_angle
    return Astronoby::Angle.zero unless observed_pair

    ParallacticAngle.at(
      equatorial: observed_pair.first.topocentric.equatorial,
      observer: @observer,
      time: closest_apparition.time
    )
  end

  def apparitions
    @apparitions ||= sightings_by_night.filter_map do |sightings|
      sightings
        .select { |sighting| still_paired?(sighting) }
        .max_by { |sighting| sighting.altitude.degrees }
    end
  end

  def visible?
    apparitions.any?
  end

  def closest_apparition
    @closest_apparition ||=
      apparitions.min_by { |sighting| sighting.separation.degrees }
  end

  def peak_night?(sighting)
    sighting.date == peak_night.date
  end

  def peak_observable?
    range = peak_night.range
    return false unless range&.cover?(peak_at)

    bodies_at(peak_at).all? do |body|
      body.topocentric.horizontal.altitude.positive?
    end
  end

  def unobservable_reason
    return :no_darkness if nights.none?(&:dark?)
    return :drifted if sightings_by_night.any?(&:any?)

    :below_horizon
  end

  private

  def still_paired?(sighting)
    sighting.separation.degrees <=
      separation.degrees + STILL_PAIRED_MARGIN.degrees
  end

  def nights
    @nights ||= (-nights_around_peak..nights_around_peak).map do |offset|
      observing_night_on(peak_night.date + offset)
    end
  end

  def nights_around_peak
    moon? ? MOON_NIGHTS_AROUND_PEAK : PLANETARY_NIGHTS_AROUND_PEAK
  end

  def peak_night
    @peak_night ||= [observing_night_on(date - 1), observing_night_on(date)]
      .min_by { |candidate| distance_from_peak(candidate) }
  end

  def sightings_by_night
    @sightings_by_night ||= nights.map do |night|
      night.times.filter_map { |time| sighting_at(night, time) }
    end
  end

  def sighting_at(night, time)
    pair = bodies_at(time)
    horizontals = pair.map { |body| body.topocentric.horizontal }
    return if horizontals.any? { |horizontal| horizontal.altitude.degrees <= 0 }

    Sighting.new(
      date: night.date,
      time: time,
      altitude: horizontals.first.altitude,
      azimuth: horizontals.first.azimuth,
      separation: pair.first.topocentric.separation_from(
        pair.second.topocentric
      )
    )
  end

  def position_angle_between(first, second)
    right_ascension_difference =
      second.right_ascension.radians - first.right_ascension.radians

    y = Math.cos(second.declination.radians) *
      Math.sin(right_ascension_difference)
    x = Math.sin(second.declination.radians) *
      Math.cos(first.declination.radians) -
      Math.cos(second.declination.radians) *
        Math.sin(first.declination.radians) *
        Math.cos(right_ascension_difference)

    Astronoby::Angle.from_radians(Math.atan2(y, x) % (2 * Math::PI))
  end

  def distance_from_peak(candidate)
    range = candidate.range
    return Float::INFINITY if range.nil?
    return 0 if range.cover?(peak_at)

    [(peak_at - range.begin).abs, (peak_at - range.end).abs].min
  end

  def bodies_at(time)
    [primary_class, secondary_class].map do |body_class|
      body_class.new(observer: @observer, time: time)
    end
  end

  def observing_night_on(date)
    ObservingNight.new(observer: @observer, date: date)
  end

  def primary_class
    @primary_class ||= if moon?
      Moon
    else
      CelestialBodies.find(@celestial_event.primary_body)
    end
  end

  def secondary_class
    @secondary_class ||= if moon?
      CelestialBodies.find(@celestial_event.primary_body)
    else
      CelestialBodies.find(@celestial_event.secondary_body)
    end
  end
end
