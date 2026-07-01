# frozen_string_literal: true

module Lunar
  class Disc
    def initialize(
      libration:,
      phase_angle:,
      bright_limb_position_angle:,
      axis_position_angle:,
      parallactic_angle:,
      catalog:
    )
      @libration = libration
      @phase_angle = phase_angle
      @bright_limb_position_angle = bright_limb_position_angle
      @axis_position_angle = axis_position_angle
      @parallactic_angle = parallactic_angle
      @catalog = catalog
    end

    def projected_features
      @projected_features ||=
        @catalog.features.filter_map { |feature| project_feature(feature) }
    end

    def terminator
      @terminator ||= Terminator.new(
        phase_angle: @phase_angle,
        bright_limb_angle: difference(
          @axis_position_angle,
          @bright_limb_position_angle
        )
      )
    end

    def orientation_angle
      @orientation_angle ||=
        difference(@parallactic_angle, @axis_position_angle)
    end

    private

    def project_feature(feature)
      points = feature
        .boundary_points
        .map { |point| project(point) }
        .select { |_x, _y, visible| visible }
        .map { |x, y, _visible| [x, y] }
      return if points.empty?

      ProjectedFeature.new(
        name: feature.name,
        kind: feature.kind,
        points: points
      )
    end

    def project(point)
      delta_longitude = point.longitude.radians - @libration.longitude.radians
      latitude_sin = Math.sin(point.latitude.radians)
      latitude_cos = Math.cos(point.latitude.radians)

      x = latitude_cos * Math.sin(delta_longitude)
      y = center_latitude_cos * latitude_sin -
        center_latitude_sin * latitude_cos * Math.cos(delta_longitude)
      cosine_distance = center_latitude_sin * latitude_sin +
        center_latitude_cos * latitude_cos * Math.cos(delta_longitude)

      [x, y, cosine_distance.positive?]
    end

    def center_latitude_sin
      @center_latitude_sin ||= Math.sin(@libration.latitude.radians)
    end

    def center_latitude_cos
      @center_latitude_cos ||= Math.cos(@libration.latitude.radians)
    end

    def sum(first, second)
      Astronoby::Angle.from_radians(first.radians + second.radians)
    end

    def difference(first, second)
      Astronoby::Angle.from_radians(first.radians - second.radians)
    end
  end
end
