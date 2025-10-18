# frozen_string_literal: true

class Visibility
  def initialize(body:, observer:, date:)
    @body = body
    @observer = observer
    @date = date
  end

  def visible?
    period_starting_today = visibility_range(
      today_body_rts,
      tomorrow_body_rts
    )
    return false unless period_starting_today && night

    today_period_is_visible = period_starting_today.overlap?(night)
    tomorrow_rise_is_visible = night.cover?(tomorrow_body_rts.rising_time)

    today_period_is_visible || tomorrow_rise_is_visible
  end

  private

  def astronoby_body
    if @body.is_a?(MessierObject)
      @body.deep_sky_object
    else
      @body.planet_class
    end
  end

  def body_rts
    Astronoby::RiseTransitSetCalculator.new(
      body: astronoby_body,
      observer: @observer,
      ephem: SPK.inpop19a
    )
  end

  def sun_rts
    Astronoby::RiseTransitSetCalculator.new(
      body: Astronoby::Sun,
      observer: @observer,
      ephem: SPK.inpop19a
    )
  end

  def twilight
    Astronoby::TwilightCalculator.new(
      observer: @observer,
      ephem: SPK.inpop19a
    )
  end

  def today_body_rts
    body_rts.event_on(@date)
  end

  def tomorrow_body_rts
    body_rts.event_on(@date + 1)
  end

  def today_sun_rts
    sun_rts.event_on(@date)
  end

  def tomorrow_sun_rts
    sun_rts.event_on(@date + 1)
  end

  def today_twilight
    twilight.event_on(@date)
  end

  def tomorrow_twilight
    twilight.event_on(@date + 1)
  end

  def night
    unless [
      today_twilight.evening_civil_twilight_time,
      today_twilight.evening_astronomical_twilight_time,
      tomorrow_twilight.morning_civil_twilight_time,
      tomorrow_twilight.morning_astronomical_twilight_time
    ].all?(&:present?)
      return nil
    end

    if @body.in?([Mercury, Venus])
      Range.new(
        today_twilight.evening_civil_twilight_time,
        tomorrow_twilight.morning_civil_twilight_time
      )
    else
      Range.new(
        today_twilight.evening_astronomical_twilight_time,
        tomorrow_twilight.morning_astronomical_twilight_time
      )
    end
  end

  def visibility_range(today_rts, tomorrow_rts)
    rising_time = today_rts.rising_time
    today_setting_time = today_rts.setting_time
    return unless rising_time && today_setting_time

    if rising_time < today_setting_time
      (rising_time..today_setting_time)
    else
      tomorrow_setting_time = tomorrow_rts.setting_time
      (rising_time..tomorrow_setting_time)
    end
  end
end
