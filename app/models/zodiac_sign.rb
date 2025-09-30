# frozen_string_literal: true

class ZodiacSign
  attr_reader :constellation, :start_date, :end_date

  ZODIAC_DATA = [
    {constellation: "cap", start_month: 12, start_day: 22, end_month: 1, end_day: 19},
    {constellation: "aqr", start_month: 1, start_day: 20, end_month: 2, end_day: 18},
    {constellation: "psc", start_month: 2, start_day: 19, end_month: 3, end_day: 20},
    {constellation: "ari", start_month: 3, start_day: 21, end_month: 4, end_day: 19},
    {constellation: "tau", start_month: 4, start_day: 20, end_month: 5, end_day: 20},
    {constellation: "gem", start_month: 5, start_day: 21, end_month: 6, end_day: 20},
    {constellation: "cnc", start_month: 6, start_day: 21, end_month: 7, end_day: 22},
    {constellation: "leo", start_month: 7, start_day: 23, end_month: 8, end_day: 22},
    {constellation: "vir", start_month: 8, start_day: 23, end_month: 9, end_day: 22},
    {constellation: "lib", start_month: 9, start_day: 23, end_month: 10, end_day: 22},
    {constellation: "sco", start_month: 10, start_day: 23, end_month: 11, end_day: 21},
    {constellation: "sgr", start_month: 11, start_day: 22, end_month: 12, end_day: 21}
  ].freeze

  def initialize(constellation, start_date, end_date)
    @constellation = constellation
    @start_date = start_date
    @end_date = end_date
  end

  def range
    [
      I18n.l(@start_date, format: :short),
      I18n.l(@end_date, format: :short)
    ].join(" - ")
  end

  def includes?(date)
    if spans_year_boundary?
      (date.month == @start_date.month && date.day >= @start_date.day) ||
        (date.month == @end_date.month && date.day <= @end_date.day)
    else
      (date.month > @start_date.month ||
       (date.month == @start_date.month && date.day >= @start_date.day)) &&
        (date.month < @end_date.month ||
         (date.month == @end_date.month && date.day <= @end_date.day))
    end
  end

  def self.for_date(date)
    all.find { |sign| sign.includes?(date) }
  end

  def self.all
    @all ||= ZODIAC_DATA.map do |data|
      start_year = (data[:start_month] > data[:end_month]) ? 1999 : 2000
      end_year = (data[:start_month] > data[:end_month]) ? 2001 : 2000

      new(
        Constellation.new(data[:constellation]),
        Date.new(start_year, data[:start_month], data[:start_day]),
        Date.new(end_year, data[:end_month], data[:end_day])
      )
    end
  end

  private

  def spans_year_boundary?
    @start_date.month > @end_date.month
  end
end
