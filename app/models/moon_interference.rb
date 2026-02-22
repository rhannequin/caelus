# frozen_string_literal: true

class MoonInterference
  def initialize(observer:, date: Time.zone.today)
    @evening_date = date
    @morning_date = date + 1
    @day_after_morning_date = date + 2
    @observer = observer
  end

  def duration
    return 0 unless night_range

    @duration ||= moon_ranges.sum do |moon_range|
      overlap_start = [night_range.begin, moon_range.begin].max
      overlap_end = [night_range.end, moon_range.end].min
      (overlap_end > overlap_start) ? overlap_end - overlap_start : 0
    end
  end

  def percentage
    return 0 unless night_range

    @percentage ||= begin
      night_duration = night_range.end - night_range.begin
      return 0 if night_duration.zero?

      ((duration / night_duration.to_f) * 100.0).round
    end
  end

  def interference
    case percentage
    when 0
      :none
    when 0...25
      :low
    when 25...50
      :moderate
    when 50...75
      :high
    when 75...100
      :extreme
    else
      :full
    end
  end

  private

  def sun_rts
    Astronoby::RiseTransitSetCalculator.new(
      body: Astronoby::Sun,
      observer: @observer,
      ephem: spk
    )
  end

  def moon_rts
    Astronoby::RiseTransitSetCalculator.new(
      body: Astronoby::Moon,
      observer: @observer,
      ephem: spk
    )
  end

  def spk
    SPK.for_time(@evening_date.to_time)
  end

  def today_sun_rts
    sun_rts.event_on(@evening_date)
  end

  def tomorrow_sun_rts
    sun_rts.event_on(@morning_date)
  end

  def today_moon_rts
    moon_rts.event_on(@evening_date)
  end

  def tomorrow_moon_rts
    moon_rts.event_on(@morning_date)
  end

  def third_day_moon_rts
    moon_rts.event_on(@day_after_morning_date)
  end

  def night_range
    return @night_range if defined?(@night_range)

    setting = today_sun_rts.setting_time
    rising = tomorrow_sun_rts.rising_time
    @night_range = (setting && rising) ? (setting..rising) : nil
  end

  def moon_ranges
    @moon_ranges ||= begin
      ranges = []

      if today_moon_rts.rising_time
        if today_moon_rts.setting_time &&
            today_moon_rts.rising_time < today_moon_rts.setting_time
          ranges << (today_moon_rts.rising_time..today_moon_rts.setting_time)
        elsif tomorrow_moon_rts.setting_time
          ranges << (today_moon_rts.rising_time..tomorrow_moon_rts.setting_time)
        end
      end

      if tomorrow_moon_rts.rising_time
        if tomorrow_moon_rts.setting_time &&
            tomorrow_moon_rts.rising_time < tomorrow_moon_rts.setting_time
          ranges << (tomorrow_moon_rts.rising_time..tomorrow_moon_rts.setting_time)
        elsif third_day_moon_rts.setting_time
          ranges << (tomorrow_moon_rts.rising_time..third_day_moon_rts.setting_time)
        end
      end

      if third_day_moon_rts.rising_time &&
          third_day_moon_rts.setting_time &&
          third_day_moon_rts.rising_time < third_day_moon_rts.setting_time
        ranges << (third_day_moon_rts.rising_time..third_day_moon_rts.setting_time)
      end

      ranges
    end
  end
end
