# frozen_string_literal: true

require "rails_helper"

RSpec.describe ElevationChartSvg, type: :model do
  describe "#generate" do
    it "generates valid SVG with elevation data" do
      elevation_points = [
        YearlyElevation::ElevationPoint
          .new(1, Date.new(2024, 1, 1), Astronoby::Angle.from_degrees(30)),
        YearlyElevation::ElevationPoint
          .new(91, Date.new(2024, 4, 1), Astronoby::Angle.from_degrees(60)),
        YearlyElevation::ElevationPoint
          .new(182, Date.new(2024, 7, 1), Astronoby::Angle.from_degrees(75)),
        YearlyElevation::ElevationPoint
          .new(274, Date.new(2024, 10, 1), Astronoby::Angle.from_degrees(45)),
        YearlyElevation::ElevationPoint
          .new(365, Date.new(2024, 12, 31), Astronoby::Angle.from_degrees(25))
      ]
      min_point = elevation_points[4]
      max_point = elevation_points[2]
      current_position = elevation_points[2]

      elevations = instance_double(
        YearlyElevation,
        data: elevation_points,
        minimum: min_point,
        maximum: max_point
      )

      generator = described_class.new(
        elevations: elevations,
        current_position: current_position
      )

      result = generator.generate
      expect(result).to include("<svg")
      expect(result).to include('viewBox="0 0 365 200"')
      expect(result).to include("<defs>")
      expect(result).to include("<linearGradient")
      expect(result).to include("<path")
      expect(result).to include("<line")
      expect(result).to include("<circle")
      expect(result).to include("</svg>")
    end

    it "marks current position with vertical line and circle" do
      elevation_point = YearlyElevation::ElevationPoint
        .new(100, Date.new(2024, 4, 10), Astronoby::Angle.from_degrees(65))
      current_position = elevation_point

      elevations = instance_double(
        YearlyElevation,
        data: [elevation_point],
        minimum: elevation_point,
        maximum: elevation_point
      )

      generator = described_class.new(
        elevations: elevations,
        current_position: current_position
      )

      result = generator.generate
      expect(result).to include('x1="99"')
      expect(result).to include('cx="99"')
      expect(result).to include('r="4"')
    end

    it "applies custom options when provided" do
      elevation_point = YearlyElevation::ElevationPoint
        .new(1, Date.new(2024, 1, 1), Astronoby::Angle.from_degrees(40))
      current_position = elevation_point
      elevations = instance_double(
        YearlyElevation,
        data: [elevation_point],
        minimum: elevation_point,
        maximum: elevation_point
      )
      custom_options = {
        width: 500,
        height: 300,
        colors: {stroke: "#FF0000"}
      }
      generator = described_class.new(
        elevations: elevations,
        current_position: current_position,
        options: custom_options
      )

      result = generator.generate
      expect(result).to include('viewBox="0 0 500 300"')
      expect(result).to include('stroke="#FF0000"')
    end

    it "handles empty elevation data" do
      empty_point = YearlyElevation::ElevationPoint
        .new(1, Date.new(2024, 1, 1), Astronoby::Angle.from_degrees(0))

      elevations = instance_double(
        YearlyElevation,
        data: [],
        minimum: empty_point,
        maximum: empty_point
      )

      generator = described_class.new(
        elevations: elevations,
        current_position: empty_point
      )

      result = generator.generate
      expect(result).to include("<svg")
      expect(result).to include("</svg>")
    end

    it "generates chart with single elevation point" do
      elevation_point = YearlyElevation::ElevationPoint
        .new(180, Date.new(2024, 6, 29), Astronoby::Angle.from_degrees(80))

      elevations = instance_double(
        YearlyElevation,
        data: [elevation_point],
        minimum: elevation_point,
        maximum: elevation_point
      )

      generator = described_class.new(
        elevations: elevations,
        current_position: elevation_point
      )

      result = generator.generate
      expect(result).to include("<svg")
      expect(result).to include('cx="179"')
      expect(result).to include("</svg>")
    end
  end
end
