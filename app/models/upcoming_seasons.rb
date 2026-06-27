# frozen_string_literal: true

class UpcomingSeasons
  include Enumerable

  Season = Struct.new(:name, :time)

  SEASON_EVENTS = %i[
    march_equinox
    june_solstice
    september_equinox
    december_solstice
  ].freeze

  DEFAULT_COUNT = 4

  def initialize(time:, count: DEFAULT_COUNT)
    @time = time
    @count = count
  end

  def each(&block)
    upcoming.each(&block)
  end

  private

  def upcoming
    @upcoming ||= two_years_of_seasons
      .select { |season| season.time >= @time }
      .sort_by(&:time)
      .first(@count)
  end

  def two_years_of_seasons
    [@time.year, @time.year + 1].flat_map do |year|
      SEASON_EVENTS.map do |event|
        Season.new(
          event,
          Astronoby::EquinoxSolstice.public_send(event, year, spk)
        )
      end
    end
  end

  def spk
    @spk ||= SPK.for_time(@time)
  end
end
