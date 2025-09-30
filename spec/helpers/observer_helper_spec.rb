# frozen_string_literal: true

require "rails_helper"

RSpec.describe ObserverHelper do
  include ObserverHelper

  describe "#format_observer_coordinates" do
    context "with positive angles" do
      it "formats using N and E" do
        observer = instance_double(
          Astronoby::Observer,
          latitude: Astronoby::Angle.from_degrees(34.0567),
          longitude: Astronoby::Angle.from_degrees(118.2543)
        )

        result = format_observer_coordinates(observer)

        expect(result).to eq("34.06° N, 118.25° E")
      end
    end

    context "with negative angles" do
      it "formats using S and W" do
        observer = instance_double(
          Astronoby::Observer,
          latitude: Astronoby::Angle.from_degrees(-33.8783),
          longitude: Astronoby::Angle.from_degrees(-151.2189)
        )

        result = format_observer_coordinates(observer)

        expect(result).to eq("33.88° S, 151.22° W")
      end
    end
  end

  describe "#cardinal_direction" do
    it "returns correct cardinal directions" do
      test_cases = {
        0 => "↑ N",
        45 => "↗ NE",
        90 => "→ E",
        135 => "↘ SE",
        180 => "↓ S",
        225 => "↙ SW",
        270 => "← W",
        315 => "↖ NW",
        360 => "↑ N",
        22.4 => "↑ N",
        22.5 => "↑ N",
        67.5 => "↗ NE",
        112.5 => "→ E",
        157.5 => "↘ SE",
        202.5 => "↓ S",
        247.5 => "↙ SW",
        292.5 => "← W",
        337.5 => "↖ NW"
      }

      test_cases.each do |degrees, expected_direction|
        result = cardinal_direction(degrees)
        expect(result).to eq(expected_direction)
      end
    end
  end
end
