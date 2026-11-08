# frozen_string_literal: true

module ObserverLocalTime
  private

  def utc_offset_of(observer)
    observer.utc_offset || 0
  end

  def local_date(time, observer)
    time.getlocal(utc_offset_of(observer)).to_date
  end

  def local_midnight(date, observer)
    Time.new(date.year, date.month, date.day, 0, 0, 0, utc_offset_of(observer))
  end
end
