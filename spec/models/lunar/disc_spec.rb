# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lunar::Disc do
  def build_disc(
    features:,
    libration_longitude: 0,
    libration_latitude: 0,
    phase_angle: 90,
    bright_limb_position_angle: 0,
    axis_position_angle: 0,
    parallactic_angle: 0
  )
    described_class.new(
      libration: Astronoby::Libration.new(
        longitude: Astronoby::Angle.from_degrees(libration_longitude),
        latitude: Astronoby::Angle.from_degrees(libration_latitude)
      ),
      phase_angle: Astronoby::Angle.from_degrees(phase_angle),
      bright_limb_position_angle:
        Astronoby::Angle.from_degrees(bright_limb_position_angle),
      axis_position_angle: Astronoby::Angle.from_degrees(axis_position_angle),
      parallactic_angle: Astronoby::Angle.from_degrees(parallactic_angle),
      catalog: Lunar::FeatureCatalog.new(features: features)
    )
  end

  def crater_at(longitude, latitude, radius: 4, name: "test")
    Lunar::Feature.crater(
      name: name,
      center: Lunar::SurfacePoint.from_degrees(longitude, latitude),
      radius: Astronoby::Angle.from_degrees(radius)
    )
  end

  def mean_x(projected_feature)
    points = projected_feature.points
    points.sum { |x, _y| x } / points.size
  end

  describe "#projected_features" do
    it "projects a feature at the sub-Earth point to the disc centre" do
      disc = build_disc(features: [crater_at(0, 0)])

      feature = disc.projected_features.first
      mean_y = feature.points.sum { |_x, y| y } / feature.points.size

      expect(mean_x(feature)).to be_within(0.02).of(0)
      expect(mean_y).to be_within(0.02).of(0)
    end

    it "places an eastern feature near the east edge of the disc" do
      disc = build_disc(features: [crater_at(80, 0)])

      expect(mean_x(disc.projected_features.first)).to be > 0.9
    end

    it "drops a far-side feature entirely" do
      disc = build_disc(features: [crater_at(150, 0)])

      expect(disc.projected_features).to be_empty
    end

    it "pulls an eastern-limb feature towards the centre under positive libration in longitude" do
      without = build_disc(features: [crater_at(85, 0)], libration_longitude: 0)
      with = build_disc(features: [crater_at(85, 0)], libration_longitude: 8)

      expect(mean_x(with.projected_features.first))
        .to be < mean_x(without.projected_features.first)
    end
  end

  describe "#terminator" do
    it "expresses the bright limb in the selenographic frame" do
      disc = build_disc(
        features: [],
        bright_limb_position_angle: 270,
        axis_position_angle: 10
      )

      expect(disc.terminator.bright_limb_angle.degrees % 360)
        .to be_within(1e-6).of(100)
    end
  end

  describe "#orientation_angle" do
    it "is the parallactic angle minus the axis position angle" do
      disc = build_disc(
        features: [],
        axis_position_angle: 20,
        parallactic_angle: 15
      )

      expect(disc.orientation_angle.degrees).to be_within(1e-6).of(-5)
    end
  end
end
