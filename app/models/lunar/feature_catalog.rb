# frozen_string_literal: true

require "json"

module Lunar
  class FeatureCatalog
    SURFACE_DATA_PATH = File.join(__dir__, "surface.json")

    SURFACE_LAYERS = {
      "shade" => :highland_shade,
      "mare" => :mare,
      "bright" => :highland_light
    }.freeze

    RAY_CRATERS = [
      {name: "tycho", longitude: -11, latitude: -43, length: 22, rays: 13}
    ].freeze

    GOLDEN_FRACTION = 0.61803398875

    CRATERS = [
      {name: "tycho", longitude: -11, latitude: -43, radius: 4},
      {name: "copernicus", longitude: -20, latitude: 10, radius: 4},
      {name: "kepler", longitude: -38, latitude: 8, radius: 3},
      {name: "aristarchus", longitude: -47, latitude: 24, radius: 3},
      {name: "plato", longitude: -9, latitude: 51, radius: 5},
      {name: "grimaldi", longitude: -68, latitude: -5, radius: 6}
    ].freeze

    RAY_HALF_ANGLE = Astronoby::Angle.from_degrees(1.5)

    def self.default
      @default ||= new(features: build_surface + build_rays + build_craters)
    end

    def self.build_surface
      bands = JSON.parse(File.read(SURFACE_DATA_PATH))
      SURFACE_LAYERS.flat_map do |band, kind|
        Array(bands[band]).each_with_index.map do |outline, index|
          Feature.patch(
            name: "#{band}_#{index + 1}",
            kind: kind,
            outline: outline.map do |lon, lat|
              SurfacePoint.from_degrees(lon, lat)
            end
          )
        end
      end
    end

    def self.build_rays
      RAY_CRATERS.flat_map { |crater| rays_for(crater) }
    end

    def self.rays_for(crater)
      center = SurfacePoint.from_degrees(crater[:longitude], crater[:latitude])
      longitude_scale = 1.0 / Math.cos(center.latitude.radians)
      crater[:rays].times.map do |index|
        jitter = (index * GOLDEN_FRACTION) % 1.0
        bearing = 2 * Math::PI * index / crater[:rays] + (jitter - 0.5) * 0.3
        length = crater[:length] * (0.6 + 0.6 * jitter)
        Feature.patch(
          name: "#{crater[:name]}_ray_#{index + 1}",
          kind: :ray,
          outline: [
            center,
            ray_tip(
              crater,
              longitude_scale,
              bearing - RAY_HALF_ANGLE.radians,
              length
            ),
            ray_tip(
              crater,
              longitude_scale,
              bearing + RAY_HALF_ANGLE.radians,
              length
            )
          ]
        )
      end
    end

    def self.ray_tip(crater, longitude_scale, bearing, length)
      SurfacePoint.from_degrees(
        crater[:longitude] + length * Math.sin(bearing) * longitude_scale,
        crater[:latitude] + length * Math.cos(bearing)
      )
    end

    def self.build_craters
      CRATERS.map do |data|
        Feature.crater(
          name: data[:name],
          center: SurfacePoint.from_degrees(data[:longitude], data[:latitude]),
          radius: Astronoby::Angle.from_degrees(data[:radius])
        )
      end
    end

    private_class_method :build_surface,
      :build_rays,
      :rays_for,
      :ray_tip,
      :build_craters

    attr_reader :features

    def initialize(features:)
      @features = features
    end
  end
end
