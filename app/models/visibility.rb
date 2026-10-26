# frozen_string_literal: true

class Visibility
  def initialize(body:, observer:, date:)
    @body = body
    @observer = observer
    @date = date
  end

  def visible?
    return false unless night
    return true if always_above_horizon?

    period_starting_today = visibility_range(
      today_body_rts,
      tomorrow_body_rts
    )
    return false unless period_starting_today

    today_period_is_visible = period_starting_today.overlap?(night)
    tomorrow_rise_is_visible = night.cover?(tomorrow_body_rts.rising_time)

    today_period_is_visible || tomorrow_rise_is_visible
  end

  private

  def always_above_horizon?
    return false unless never_rises_nor_sets?

    altitude.positive?
  end

  def never_rises_nor_sets?
    today_body_rts.rising_time.nil? && today_body_rts.setting_time.nil?
  end

  def altitude
    @altitude ||= @body
      .at(sample_time, observer: @observer)
      .topocentric
      .horizontal
      .altitude
  end

  def sample_time
    @date.noon
  end

  def body_rts
    @body_rts ||= Astronoby::RiseTransitSetCalculator.new(
      body: @body.astronoby_body,
      observer: @observer,
      ephem: spk
    )
  end

  def today_body_rts
    @today_body_rts ||= body_rts.event_on(@date)
  end

  def tomorrow_body_rts
    @tomorrow_body_rts ||= body_rts.event_on(@date + 1)
  end

  def observing_night
    @observing_night ||= ObservingNight.new(observer: @observer, date: @date)
  end

  def night
    return @night if defined?(@night)

    @night =
      if @body.in?([Mercury, Venus])
        observing_night.range(darkness: :civil)
      else
        observing_night.range
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

  def spk
    @spk ||= SPK.for_time(@date.to_time)
  end
end
