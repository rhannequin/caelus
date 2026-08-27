# frozen_string_literal: true

class ObservingNight
  SAMPLE_COUNT = 12
  SCAN_STEP = 10 * 60
  SCAN_REFINEMENTS = 12

  DARKNESS_ALTITUDES = {
    astronomical: Astronoby::Angle.from_degrees(-18),
    nautical: Astronoby::Angle.from_degrees(-12),
    civil: Astronoby::Angle.from_degrees(-6)
  }.freeze

  DARKNESS_LEVELS = {
    astronomical: [
      :evening_astronomical_twilight_time,
      :morning_astronomical_twilight_time
    ],
    nautical: [
      :evening_nautical_twilight_time,
      :morning_nautical_twilight_time
    ],
    civil: [
      :evening_civil_twilight_time,
      :morning_civil_twilight_time
    ]
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

    window_at(darkness)
  end

  def dark?
    !range.nil?
  end

  def full_darkness?
    darkness == :astronomical
  end

  def duration
    return 0 unless dark?

    range.end - range.begin
  end

  def times
    return [] unless dark?

    step = duration / SAMPLE_COUNT
    (0..SAMPLE_COUNT).map { |index| range.begin + step * index }
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
    @deepest_window ||= DARKNESS_LEVELS
      .keys
      .lazy
      .filter_map { |level| window_for(level) }
      .first || scanned_window
  end

  def scanned_window
    DARKNESS_LEVELS
      .keys
      .lazy
      .filter_map { |level| scanned_window_for(level) }
      .first || {darkness: :none, range: nil}
  end

  def scanned_window_for(level)
    limit = DARKNESS_ALTITUDES.fetch(level)
    dark = solar_altitudes.each_index.select { |i| solar_altitudes[i] <= limit }
    return if dark.empty?

    first, last = longest_run(dark)
    return if first == last

    {
      darkness: level,
      range: crossing(first, -1, limit)..crossing(last, 1, limit)
    }
  end

  def solar_altitudes
    @solar_altitudes ||= scan_times.map { |time| solar_altitude_at(time) }
  end

  def scan_times
    @scan_times ||= begin
      noon = Time.new(@date.year, @date.month, @date.day, 12, 0, 0, utc_offset)
      steps = (24 * 3600 / SCAN_STEP)
      (0..steps).map { |step| noon + step * SCAN_STEP }
    end
  end

  def solar_altitude_at(time)
    Astronoby::Sun
      .new(instant: Astronoby::Instant.from_time(time), ephem: spk)
      .observed_by(@observer)
      .horizontal
      .altitude
  end

  def longest_run(indexes)
    runs = indexes.slice_when { |a, b| b != a + 1 }.to_a
    longest = runs.max_by(&:size)

    [longest.first, longest.last]
  end

  def crossing(index, direction, limit)
    inside = scan_times[index]
    outside_index = index + direction
    return inside if outside_index.negative?

    outside = scan_times[outside_index]
    return inside unless outside

    SCAN_REFINEMENTS.times do
      middle = inside + (outside - inside) / 2
      if solar_altitude_at(middle) <= limit
        inside = middle
      else
        outside = middle
      end
    end

    inside
  end

  def window_for(level)
    range = window_at(level)
    return unless range

    {darkness: level, range: range}
  end

  def window_at(level)
    evening_time, morning_time = DARKNESS_LEVELS.fetch(level)
    from = evening_twilight.public_send(evening_time)
    to = morning_twilight.public_send(morning_time)
    return unless from && to

    from..to
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

  def evening_twilight
    @evening_twilight ||= twilight_calculator.event_on(@date, utc_offset: utc_offset)
  end

  def morning_twilight
    @morning_twilight ||=
      twilight_calculator.event_on(@date + 1, utc_offset: utc_offset)
  end

  def utc_offset
    @observer.utc_offset || 0
  end

  def twilight_calculator
    @twilight_calculator ||= Astronoby::TwilightCalculator.new(
      observer: @observer,
      ephem: spk
    )
  end

  def spk
    @spk ||= SPK.for_time(@date.to_time)
  end
end
