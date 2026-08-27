# frozen_string_literal: true

require "rails_helper"

RSpec.describe AngularSeparation do
  describe ".between" do
    it "is zero for a coordinate compared with itself" do
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(5, 34, 32),
        declination: Astronoby::Angle.from_dms(22, 0, 52)
      )

      separation = described_class.between(coordinates, coordinates)

      expect(separation.degrees).to be_within(0.0001).of(0)
    end

    it "is 180 degrees for opposite points on the sphere" do
      north = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.from_degrees(90)
      )
      south = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.from_degrees(-90)
      )

      expect(described_class.between(north, south).degrees)
        .to be_within(0.0001).of(180)
    end

    it "measures the known separation between M81 and M82" do
      m81 = MessierCatalog.find_by_number(81).j2000_coordinates
      m82 = MessierCatalog.find_by_number(82).j2000_coordinates

      separation = described_class.between(m81, m82)

      expect(separation.degrees).to be_within(0.05).of(0.62)
    end
  end
end
