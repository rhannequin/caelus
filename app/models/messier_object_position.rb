# frozen_string_literal: true

class MessierObjectPosition
  include ActiveModel::Model

  Culmination = Data.define(:altitude, :time)

  attr_accessor :messier_object, :time, :observer, :use_ephem, :night

  def topocentric
    @topocentric ||= messier_object
      .deep_sky_object
      .at(instant, ephem: (use_ephem ? spk : nil))
      .observed_by(observer)
  end

  def rts
    @rts ||= rts_calculator.event_on(time.to_date)
  end

  def highest_altitude
    culmination&.altitude
  end

  def highest_altitude_time
    culmination&.time
  end

  private

  def culmination
    return if candidate_times.empty?

    @culmination ||= candidate_times
      .map { |candidate| Culmination.new(altitude_at(candidate), candidate) }
      .max_by(&:altitude)
  end

  def candidate_times
    return [] unless night&.dark?

    @candidate_times ||=
      [night.range.begin, night.range.end] + transit_times_during_night
  end

  def transit_times_during_night
    [rts, next_day_rts]
      .filter_map(&:transit_time)
      .select { |transit_time| night.range.cover?(transit_time) }
  end

  def next_day_rts
    @next_day_rts ||= rts_calculator.event_on(time.to_date + 1)
  end

  def altitude_at(moment)
    messier_object
      .deep_sky_object
      .at(Astronoby::Instant.from_time(moment), ephem: spk)
      .observed_by(observer)
      .horizontal
      .altitude
  end

  def rts_calculator
    @rts_calculator ||= Astronoby::RiseTransitSetCalculator.new(
      body: messier_object.deep_sky_object,
      observer: observer,
      ephem: spk
    )
  end

  def instant
    @instant ||= Astronoby::Instant.from_time(time)
  end

  def spk
    @spk ||= SPK.for_time(time)
  end
end
