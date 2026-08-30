# frozen_string_literal: true

class LunarEclipseContact
  attr_reader :key, :instant, :geometry

  def initialize(key:, instant:, geometry:, observer:)
    @key = key
    @instant = instant
    @geometry = geometry
    @observer = observer
  end

  def time
    @time ||= @instant.to_time
  end

  delegate :position_angle, to: :@geometry
  delegate :altitude, :azimuth, to: :horizontal

  def above_horizon?
    altitude.positive?
  end

  private

  def horizontal
    @horizontal ||= Astronoby::Moon
      .new(ephem: SPK.for_time(time), instant: @instant)
      .observed_by(@observer)
      .horizontal
  end
end
