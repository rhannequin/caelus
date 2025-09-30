# frozen_string_literal: true

class HebrewCalendar
  # Julian Day Number offset for Hebrew calendar epoch (September 7, 3761 BCE)
  HEBREW_EPOCH_OFFSET = 347997

  MONTH_NAMES = %w[
    Nisan
    Iyar
    Sivan
    Tammuz
    Av
    Elul
    Tishrei
    Cheshvan
    Kislev
    Tevet
    Shevat
    Adar
    Adar\ II
  ].freeze

  # Days of week for postponement rules
  MONDAY = 1
  TUESDAY = 2
  WEDNESDAY = 3
  THURSDAY = 4
  FRIDAY = 5
  SATURDAY = 6
  SUNDAY = 0

  # Astronomical calculation constants
  MONTHS_IN_19_YEAR_CYCLE = 235
  PARTS_PER_HOUR = 1080
  HOURS_PER_DAY = 24
  INITIAL_PARTS = 204
  PARTS_PER_MONTH_FRACTION = 793
  INITIAL_HOURS = 5
  HOURS_PER_MONTH = 12
  DAYS_PER_MONTH = 29
  MOLAD_NOON_THRESHOLD = 19_440
  COMMON_YEAR_TUESDAY_THRESHOLD = 9_924
  LEAP_YEAR_MONDAY_THRESHOLD = 16_789
  POSTPONED_DAYS = [SUNDAY, WEDNESDAY, FRIDAY].freeze

  # Months with fixed lengths
  # Nisan, Sivan, Av, Tishrei, Shevat
  THIRTY_DAY_MONTHS = [1, 3, 5, 7, 11].freeze
  # Iyar, Tammuz, Elul, Tevet, Adar II
  TWENTY_NINE_DAY_MONTHS = [2, 4, 6, 10, 13].freeze
  CHESHVAN = 8
  KISLEV = 9
  ADAR = 12

  attr_reader :year, :month, :day

  def self.date_for(time)
    new(time).to_a
  end

  def self.formatted_date_for(time)
    new(time).to_formatted_string
  end

  def initialize(time)
    @gregorian_time = time
    @year, @month, @day = convert_to_hebrew_date
  end

  def to_a
    [year, month, day]
  end

  def to_formatted_string
    "#{day} #{month_name} #{year}"
  end

  def leap_year?
    hebrew_leap_year?(year)
  end

  def year_length
    calculate_year_length(year)
  end

  def month_name
    MONTH_NAMES[month - 1]
  end

  private

  def convert_to_hebrew_date
    julian_day = gregorian_to_julian_day
    julian_day_to_hebrew_date(julian_day)
  end

  def gregorian_to_julian_day
    Date.new(
      @gregorian_time.year,
      @gregorian_time.month,
      @gregorian_time.day
    ).jd
  end

  def julian_day_to_hebrew_date(julian_day)
    days_since_epoch = julian_day - HEBREW_EPOCH_OFFSET
    year = estimate_hebrew_year(days_since_epoch)
    year = find_exact_hebrew_year(year, days_since_epoch)

    find_month_and_day(year, days_since_epoch)
  end

  def estimate_hebrew_year(days_since_epoch)
    (days_since_epoch / 365).floor + 2
  end

  def find_exact_hebrew_year(estimated_year, days_since_epoch)
    year = estimated_year
    first_day = calculate_elapsed_days(year)

    while first_day > days_since_epoch
      year -= 1
      first_day = calculate_elapsed_days(year)
    end

    year
  end

  def find_month_and_day(year, days_since_epoch)
    months = hebrew_months_list(year)
    days_remaining = days_since_epoch - calculate_elapsed_days(year)

    months.each do |month|
      month_days = calculate_month_length(year, month)

      if days_remaining >= month_days
        days_remaining -= month_days
      else
        return [year, month, days_remaining + 1]
      end
    end

    raise ArgumentError, "Unable to convert date - calculation error"
  end

  def hebrew_leap_year?(year)
    ((7 * year + 1) % 19) < 7
  end

  def calculate_elapsed_months(year)
    ((MONTHS_IN_19_YEAR_CYCLE * year - 234) / 19).floor
  end

  def calculate_elapsed_days(year)
    months_elapsed = calculate_elapsed_months(year)
    parts_elapsed = INITIAL_PARTS +
      PARTS_PER_MONTH_FRACTION * (months_elapsed % PARTS_PER_HOUR)

    hours_elapsed = calculate_hours_elapsed(months_elapsed, parts_elapsed)
    conjunction_day = 1 +
      DAYS_PER_MONTH * months_elapsed +
      (hours_elapsed / HOURS_PER_DAY).floor
    conjunction_parts = PARTS_PER_HOUR * (hours_elapsed % HOURS_PER_DAY) +
      parts_elapsed % PARTS_PER_HOUR

    apply_postponement_rules(conjunction_day, conjunction_parts, year)
  end

  def calculate_hours_elapsed(months_elapsed, parts_elapsed)
    INITIAL_HOURS + HOURS_PER_MONTH * months_elapsed +
      PARTS_PER_MONTH_FRACTION * (months_elapsed / PARTS_PER_HOUR).floor +
      (parts_elapsed / PARTS_PER_HOUR).floor
  end

  def apply_postponement_rules(conjunction_day, conjunction_parts, year)
    alt_day = apply_molad_rules(conjunction_day, conjunction_parts, year)
    apply_day_of_week_rules(alt_day)
  end

  def apply_molad_rules(conjunction_day, conjunction_parts, year)
    if molad_postponement_required?(conjunction_day, conjunction_parts, year)
      conjunction_day + 1
    else
      conjunction_day
    end
  end

  def molad_postponement_required?(conjunction_day, conjunction_parts, year)
    conjunction_parts >= MOLAD_NOON_THRESHOLD ||
      common_year_tuesday_rule?(conjunction_day, conjunction_parts, year) ||
      leap_year_monday_rule?(conjunction_day, conjunction_parts, year)
  end

  def common_year_tuesday_rule?(conjunction_day, conjunction_parts, year)
    (conjunction_day % 7 == TUESDAY) &&
      (conjunction_parts >= COMMON_YEAR_TUESDAY_THRESHOLD) &&
      !hebrew_leap_year?(year)
  end

  def leap_year_monday_rule?(conjunction_day, conjunction_parts, year)
    (conjunction_day % 7 == MONDAY) &&
      (conjunction_parts >= LEAP_YEAR_MONDAY_THRESHOLD) &&
      hebrew_leap_year?(year - 1)
  end

  def apply_day_of_week_rules(alt_day)
    alt_day += 1 if POSTPONED_DAYS.include?(alt_day % 7)
    alt_day
  end

  def hebrew_months_list(year)
    months = [7, 8, 9, 10, 11, 12, 13, 1, 2, 3, 4, 5, 6]
    months.delete(13) unless hebrew_leap_year?(year)
    months
  end

  def calculate_month_length(year, month)
    case month
    when *THIRTY_DAY_MONTHS
      30
    when *TWENTY_NINE_DAY_MONTHS
      29
    when CHESHVAN
      long_cheshvan?(year) ? 30 : 29
    when KISLEV
      short_kislev?(year) ? 29 : 30
    when ADAR
      hebrew_leap_year?(year) ? 30 : 29
    else
      raise ArgumentError, "Invalid Hebrew month: #{month}"
    end
  end

  def long_cheshvan?(year)
    calculate_year_length(year) % 10 == 5
  end

  def short_kislev?(year)
    calculate_year_length(year) % 10 == 3
  end

  def calculate_year_length(year)
    calculate_elapsed_days(year + 1) - calculate_elapsed_days(year)
  end
end
