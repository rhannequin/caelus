# frozen_string_literal: true

class YearlyElevation
  ElevationPoint = Struct.new(:yday, :date, :elevation)

  def initialize(year:, body:, observer:, samples: 365)
    @year = year
    @body = body
    @observer = observer
    @samples = samples
  end

  def data
    @data ||= begin
      data_points = []

      (0...@samples).each do |day_offset|
        date = start_date + day_offset.days
        transit_time = transit_times[day_offset]
        elevation = elevation_at(transit_time)

        data_points << ElevationPoint.new(
          day_offset + 1,
          date,
          elevation
        )
      end

      data_points
    end
  end

  def minimum
    @minimum ||= data.min_by(&:elevation)
  end

  def maximum
    @maximum ||= data.max_by(&:elevation)
  end

  def current(time)
    current_day_of_year = time.yday
    data.find { |point| point.yday == current_day_of_year } ||
      data.first
  end

  private

  def start_date
    Date.new(@year, 1, 1)
  end

  def end_date
    start_date + @samples
  end

  def transit_times
    @transit_times ||= Astronoby::RiseTransitSetCalculator
      .new(body: @body.planet_class, observer: @observer, ephem: SPK.inpop19a)
      .events_between(start_date.to_time, end_date.to_time)
      .transit_times
  end

  def elevation_at(time)
    sun = @body.new(observer: @observer, time: time)
    elevation = sun.topocentric.horizontal.altitude

    elevation.positive? ? elevation : Astronoby::Angle.zero
  end
end
