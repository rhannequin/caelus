# frozen_string_literal: true

class Moon
  class Angle < Astronoby::Angle; end

  SECONDS_PER_DAY = 86_400.0
  SYNODIC_MONTH_DAYS = 29.530588853
  HALF_SYNODIC_PERIOD = SYNODIC_MONTH_DAYS / 2.0
  CRESCENT_RANGES = [
    [Angle.from_degrees(12), Angle.from_degrees(81)],
    [Angle.from_degrees(279), Angle.from_degrees(348)]
  ].freeze
  QUARTER_RANGES = [
    [Angle.from_degrees(81), Angle.from_degrees(99)],
    [Angle.from_degrees(261), Angle.from_degrees(279)]
  ].freeze
  GIBBOUS_RANGES = [
    [Angle.from_degrees(99), Angle.from_degrees(168)],
    [Angle.from_degrees(192), Angle.from_degrees(261)]
  ].freeze
  FULL_MOON_RANGE = [
    Angle.from_degrees(168), Angle.from_degrees(192)
  ].freeze

  AXIAL_TILT_DEGREES = 5.145
  ESCAPE_VELOCITY_KMPS = 2.38
  GRAVITY_MPS2 = 1.62
  MEAN_RADIUS_KM = 1737.4
  ORBITAL_PERIOD_DAYS = 27.321661

  include Planetable

  def self.planet_class
    Astronoby::Moon
  end

  def self.key
    :moon
  end

  def initialize(observer:, time: Time.now)
    @observer = observer
    @time = time
  end

  delegate :phase_angle, to: :planet

  def age
    @age ||= begin
      previous_month_time = @time.prev_month
      previous_month_phases = Astronoby::Events::MoonPhases.phases_for(
        year: previous_month_time.year,
        month: previous_month_time.month
      )
      current_month_phases = Astronoby::Events::MoonPhases.phases_for(
        year: @time.year,
        month: @time.month
      )

      most_recent_passed_new_moon =
        (previous_month_phases + current_month_phases)
          .select do |moon_phase|
          moon_phase.time <= @time && moon_phase.phase == :new_moon
        end.max_by(&:time)

      (@time - most_recent_passed_new_moon.time) / SECONDS_PER_DAY
    end
  end

  def current_phase_name
    shifted_angle = (phase_angle.degrees + 180.0)
    angle = Astronoby::Angle.from_degrees(shifted_angle)
    before_full_moon = age <= HALF_SYNODIC_PERIOD

    if CRESCENT_RANGES.any? { |range| angle.between?(*range) }
      before_full_moon ? :waxing_crescent : :waning_crescent
    elsif QUARTER_RANGES.any? { |range| angle.between?(*range) }
      before_full_moon ? :first_quarter : :last_quarter
    elsif GIBBOUS_RANGES.any? { |range| angle.between?(*range) }
      before_full_moon ? :waxing_gibbous : :waning_gibbous
    elsif angle.between?(*FULL_MOON_RANGE)
      :full_moon
    else
      :new_moon
    end
  end

  def next_phase
    @next_phase ||= begin
      current_month_phases = Astronoby::Events::MoonPhases.phases_for(
        year: @time.year,
        month: @time.month
      )
      next_month_time = @time.next_month
      next_month_phases = Astronoby::Events::MoonPhases.phases_for(
        year: next_month_time.year,
        month: next_month_time.month
      )

      (current_month_phases + next_month_phases)
        .select { |moon_phase| moon_phase.time > @time }
        .min_by(&:time)
    end
  end

  def velocity
    @velocity ||=
      (planet.geometric.velocity - current_earth_geometric.velocity).magnitude
  end
end
