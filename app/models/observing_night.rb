# frozen_string_literal: true

class ObservingNight
  include ObserverLocalTime

  SAMPLE_COUNT = 12
  ALL_DAY = 24 * 3600
  ALL_DAY_TOLERANCE = 10 * 60

  DARKNESS_ALTITUDES = {
    astronomical: Astronoby::Angle.from_degrees(-18),
    nautical: Astronoby::Angle.from_degrees(-12),
    civil: Astronoby::Angle.from_degrees(-6)
  }.freeze

  MoonPosition = Data.define(
    :time,
    :altitude,
    :equatorial,
    :illuminated_fraction
  )

  attr_reader :date

  def initialize(observer:, date:)
    @observer = observer
    @date = date
  end

  def darkness
    deepest_window.fetch(:darkness)
  end

  def range(darkness: nil)
    return deepest_window.fetch(:range) if darkness.nil?

    window_for(darkness)&.fetch(:range)
  end

  def dark?
    !range.nil?
  end

  def full_darkness?
    darkness == :astronomical
  end

  def all_day?
    dark? && duration >= ALL_DAY - ALL_DAY_TOLERANCE
  end

  def duration
    return 0 unless dark?

    range.end - range.begin
  end

  def times
    return [] unless dark?

    step = duration / SAMPLE_COUNT
    (0...SAMPLE_COUNT).map { |index| range.begin + step * index } << range.end
  end

  def moon_positions
    @moon_positions ||= times.map do |time|
      moon = Astronoby::Moon.new(
        instant: Astronoby::Instant.from_time(time),
        ephem: spk
      )
      observed = moon.observed_by(@observer)

      MoonPosition.new(
        time: time,
        altitude: observed.horizontal.altitude,
        equatorial: observed.equatorial,
        illuminated_fraction: moon.illuminated_fraction
      )
    end
  end

  def moon_illuminated_fraction
    moon_positions.map(&:illuminated_fraction).max || 0.0
  end

  def moonless_range
    @moonless_range ||= longest_moonless_stretch
  end

  def track(body)
    times.map do |time|
      body
        .at(Astronoby::Instant.from_time(time), ephem: spk)
        .observed_by(@observer)
    end
  end

  private

  def deepest_window
    windows.values.compact.first || {darkness: :none, range: nil}
  end

  def window_for(level)
    windows.fetch(level)
  end

  def windows
    @windows ||= begin
      crossings = crossing_calculator.multiple_crossings_between(
        noon,
        noon + ALL_DAY,
        altitudes: DARKNESS_ALTITUDES.values
      )

      DARKNESS_ALTITUDES.keys.zip(DARKNESS_ALTITUDES.values, crossings)
        .to_h { |level, limit, found| [level, window(level, limit, found)] }
    end
  end

  def window(level, limit, crossings)
    longest = dark_stretches(crossings, limit)
      .select { |stretch| span(stretch).positive? }
      .max_by { |stretch| span(stretch) }

    {darkness: level, range: longest} if longest
  end

  def dark_stretches(crossings, limit)
    start = noon if dark_at_noon?(crossings, limit)

    stretches = crossings.each_with_object([]) do |crossing, found|
      time = crossing.instant.to_time

      if crossing.direction == :setting
        start = time
      elsif start
        found << (start..time)
        start = nil
      end
    end

    start ? stretches << (start..noon + ALL_DAY) : stretches
  end

  def dark_at_noon?(crossings, limit)
    return solar_altitude_at(noon) <= limit if crossings.empty?

    crossings.first.direction == :rising
  end

  def noon
    @noon ||= Time.new(@date.year, @date.month, @date.day, 12, 0, 0, utc_offset_of(@observer))
  end

  def solar_altitude_at(time)
    Astronoby::Sun
      .new(instant: Astronoby::Instant.from_time(time), ephem: spk)
      .observed_by(@observer)
      .horizontal
      .altitude
  end

  def longest_moonless_stretch
    longest = nil
    start = nil

    moon_positions.each do |position|
      if position.altitude.negative?
        start ||= position.time
        candidate = start..position.time
        longest = candidate if longest.nil? || span(candidate) > span(longest)
      else
        start = nil
      end
    end

    longest if longest && span(longest).positive?
  end

  def span(range)
    range.end - range.begin
  end

  def crossing_calculator
    @crossing_calculator ||= Astronoby::AltitudeCrossingCalculator.new(
      body: Astronoby::Sun,
      observer: @observer,
      ephem: spk
    )
  end

  def spk
    @spk ||= SPK.for_time(@date.to_time)
  end
end
