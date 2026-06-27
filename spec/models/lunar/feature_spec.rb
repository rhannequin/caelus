# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lunar::Feature do
  describe ".mare" do
    it "is a mare drawn from its outline" do
      outline = [
        Lunar::SurfacePoint.from_degrees(0, 0),
        Lunar::SurfacePoint.from_degrees(10, 0),
        Lunar::SurfacePoint.from_degrees(5, 10)
      ]

      feature = described_class.mare(name: "imbrium", outline: outline)

      expect(feature).to be_mare
      expect(feature).not_to be_crater
      expect(feature.boundary_points).to eq(outline)
    end
  end

  describe ".crater" do
    def sample_crater
      described_class.crater(
        name: "tycho",
        center: Lunar::SurfacePoint.from_degrees(-11, -43),
        radius: Astronoby::Angle.from_degrees(5)
      )
    end

    it "is a crater, not an outline feature" do
      crater = sample_crater

      expect(crater).to be_crater
      expect(crater).not_to be_mare
    end

    it "traces a rim around its centre" do
      points = sample_crater.boundary_points

      expect(points.size).to eq(described_class::DEFAULT_RIM_SEGMENTS)
      expect(points).to all(be_a(Lunar::SurfacePoint))
    end

    it "keeps the rim within roughly its angular radius of the centre" do
      latitudes = sample_crater.boundary_points.map { |p| p.latitude.degrees }

      expect(latitudes.max).to be_within(0.5).of(-43 + 5)
      expect(latitudes.min).to be_within(0.5).of(-43 - 5)
    end
  end

  describe ".patch" do
    it "is an outline feature of the given kind" do
      outline = [
        Lunar::SurfacePoint.from_degrees(0, 0),
        Lunar::SurfacePoint.from_degrees(10, 0),
        Lunar::SurfacePoint.from_degrees(5, 10)
      ]

      feature = described_class.patch(name: "ray", kind: :ray, outline: outline)

      expect(feature.kind).to eq(:ray)
      expect(feature.boundary_points).to eq(outline)
      expect(feature).not_to be_mare
      expect(feature).not_to be_crater
    end
  end

  it "is immutable" do
    feature = described_class.crater(
      name: "tycho",
      center: Lunar::SurfacePoint.from_degrees(0, 0),
      radius: Astronoby::Angle.from_degrees(1)
    )

    expect(feature).to be_frozen
  end
end
