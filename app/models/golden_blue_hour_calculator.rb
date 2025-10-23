# frozen_string_literal: true

class GoldenBlueHourCalculator
  GOLDEN_HOUR_ZENITH_ANGLE = Astronoby::Angle.from_degrees(84)
  BLUE_HOUR_ZENITH_ANGLES = [
    Astronoby::Angle.from_degrees(94),
    Astronoby::Angle.from_degrees(96)
  ].freeze

  def initialize(observer:, date:)
    @observer = observer
    @date = date
  end

  def morning_golden_hour
    [
      sun.rts.rising_time,
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: GOLDEN_HOUR_ZENITH_ANGLE,
        utc_offset: @observer.utc_offset
      )
    ]
  end

  def evening_golden_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: GOLDEN_HOUR_ZENITH_ANGLE,
        utc_offset: @observer.utc_offset
      ),
      sun.rts.setting_time
    ]
  end

  def morning_blue_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.second,
        utc_offset: @observer.utc_offset
      ),
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.first,
        utc_offset: @observer.utc_offset
      )
    ]
  end

  def evening_blue_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.first,
        utc_offset: @observer.utc_offset
      ),
      twilight_calculator.time_for_zenith_angle(
        date: @date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.second,
        utc_offset: @observer.utc_offset
      )
    ]
  end

  private

  def sun
    @sun ||= Sun.new(
      observer: @observer,
      time: @date.to_time
    )
  end

  def twilight_calculator
    @twilight_calculator ||= Astronoby::TwilightCalculator.new(
      observer: @observer,
      ephem: SPK.inpop19a
    )
  end
end
