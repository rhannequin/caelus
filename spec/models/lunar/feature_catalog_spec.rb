# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lunar::FeatureCatalog do
  describe ".default" do
    it "includes the maria, highland mottle, rays and craters" do
      kinds = described_class.default.features.map(&:kind).uniq

      expect(kinds)
        .to include(:mare, :highland_shade, :highland_light, :ray, :crater)
    end

    it "keeps every feature on the near side" do
      longitudes = described_class.default.features.flat_map do |feature|
        feature.boundary_points.map { |point| point.longitude.degrees }
      end

      expect(longitudes).to all(be_between(-90, 90))
    end

    it "gives every mare a closed-enough outline to fill" do
      maria = described_class.default.features.select(&:mare?)

      expect(maria).to all(satisfy { |mare| mare.boundary_points.size >= 3 })
    end
  end

  describe "injection" do
    it "exposes the features it was built with" do
      feature = Lunar::Feature.crater(
        name: "tycho",
        center: Lunar::SurfacePoint.from_degrees(-11, -43),
        radius: Astronoby::Angle.from_degrees(5)
      )

      catalog = described_class.new(features: [feature])

      expect(catalog.features).to eq([feature])
    end
  end
end
