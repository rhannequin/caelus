# frozen_string_literal: true

class ObservingNight
  SAMPLE_COUNT = 12

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
      .first || {darkness: :none, range: nil}
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
    @evening_twilight ||= twilight_calculator.event_on(@date)
  end

  def morning_twilight
    @morning_twilight ||= twilight_calculator.event_on(@date + 1)
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
