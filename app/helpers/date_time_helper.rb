# frozen_string_literal: true

module DateTimeHelper
  def nillable_datetime(datetime, utc_offset: "+00:00", format: :default)
    if datetime.nil?
      "∅"
    else
      I18n.l(datetime.localtime(utc_offset), format: format)
    end
  end

  def duration_to_human(duration)
    sign = (duration < 0) ? "-" : ""
    abs_duration = duration.abs
    hours = abs_duration / 3600
    minutes = (abs_duration % 3600) / 60
    seconds = abs_duration % 60
    minute_symbol = I18n.t("units.duration.minute.symbol")

    if hours.to_i > 0
      hour_symbol = I18n.t("units.duration.hour.symbol")
      "#{sign}#{hours.to_i}#{hour_symbol} #{minutes.to_i}#{minute_symbol}"
    else
      second_symbol = I18n.t("units.duration.second.symbol")
      "#{sign}#{minutes.to_i}#{minute_symbol} #{seconds.to_i}#{second_symbol}"
    end
  end
end
