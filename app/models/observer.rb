# frozen_string_literal: true

class Observer
  attr_reader :time_zone

  def initialize(astronoby_observer:, time_zone:)
    @astronoby_observer = astronoby_observer
    @time_zone = time_zone
    validate!
  end

  delegate :latitude,
    :longitude,
    :utc_offset,
    :earth_fixed_rotation_matrix_for,
    :geocentric_position,
    :geocentric_velocity,
    to: :@astronoby_observer

  private

  def validate!
    unless @astronoby_observer.is_a?(Astronoby::Observer)
      raise ArgumentError, "astronoby_observer must be a Astronoby::Observer"
    end

    unless time_zone.is_a?(ActiveSupport::TimeZone)
      raise ArgumentError, "time_zone must be a ActiveSupport::TimeZone"
    end
  end
end
