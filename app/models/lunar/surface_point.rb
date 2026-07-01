# frozen_string_literal: true

module Lunar
  SurfacePoint = Data.define(:longitude, :latitude) do
    def self.from_degrees(longitude, latitude)
      new(
        longitude: Astronoby::Angle.from_degrees(longitude),
        latitude: Astronoby::Angle.from_degrees(latitude)
      )
    end
  end
end
