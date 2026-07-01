# frozen_string_literal: true

module Lunar
  Feature = Data.define(:name, :kind, :outline, :center, :radius)

  class Feature
    CRATER = :crater
    DEFAULT_RIM_SEGMENTS = 24

    def self.mare(name:, outline:)
      patch(name: name, kind: :mare, outline: outline)
    end

    def self.patch(name:, kind:, outline:)
      new(name: name, kind: kind, outline: outline, center: nil, radius: nil)
    end

    def self.crater(name:, center:, radius:)
      new(
        name: name,
        kind: CRATER,
        outline: nil,
        center: center,
        radius: radius
      )
    end

    def mare?
      kind == :mare
    end

    def crater?
      kind == CRATER
    end

    def boundary_points(rim_segments: DEFAULT_RIM_SEGMENTS)
      outline || rim_points(rim_segments)
    end

    private

    def rim_points(segments)
      longitude = center.longitude.degrees
      latitude = center.latitude.degrees
      angular_radius = radius.degrees
      longitude_scale = 1.0 / Math.cos(center.latitude.radians)

      Array.new(segments) do |index|
        angle = 2 * Math::PI * index / segments
        SurfacePoint.from_degrees(
          longitude + angular_radius * Math.cos(angle) * longitude_scale,
          latitude + angular_radius * Math.sin(angle)
        )
      end
    end
  end
end
