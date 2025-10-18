# frozen_string_literal: true

class MessierObjectPosition
  include ActiveModel::Model

  attr_accessor :messier_object, :time, :observer, :use_ephem

  def topocentric
    @topocentric ||= messier_object
      .deep_sky_object
      .at(instant, ephem: (use_ephem ? SPK.inpop19a : nil))
      .observed_by(observer)
  end

  def rts
    @rts ||= Astronoby::RiseTransitSetCalculator.new(
      body: messier_object.deep_sky_object,
      observer: observer,
      ephem: SPK.inpop19a
    ).event_on(time.to_date)
  end

  def visibility
    @visibility ||= Visibility.new(
      body: messier_object,
      observer: @observer,
      date: @time.to_date
    )
  end

  private

  def instant
    @instant ||= Astronoby::Instant.from_time(time)
  end
end
