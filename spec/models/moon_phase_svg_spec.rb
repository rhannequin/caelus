# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoonPhaseSvg, type: :model do
  describe "#draw" do
    context "when the moon is a waxing crescent" do
      it "generates a waxing crescent SVG" do
        moon = instance_double(
          Moon,
          phase_angle: Astronoby::Angle.from_degrees(125.5),
          age: 4.7
        )
        moon_phase_svg = described_class.new(moon)

        output = moon_phase_svg.draw.gsub(/\s+/, " ").strip

        expected = <<SVG
          <svg
            width="400"
            height="400"
            viewBox="0 0 400 400"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <clipPath>
                <circle cx="200.0" cy="200.0" r="179.0"/>
              </clipPath>
            </defs>
            <circle
              cx="200.0"
              cy="200.0"
              r="179.0"
              fill="#faf8f0"
              stroke="#666"
              stroke-width="2"
            />
            <path
              d="M 200.0 21.0 A 179.0 179.0 0 0 0 200.0 379.0 A 103.94582907225822 179.0 0 1 0 200.0 21.0"
              fill="#1a1a1a"
            />
         </svg>
SVG
          .gsub(/\s+/, " ")
          .strip

        expect(output).to eq(expected)
      end
    end

    context "when the moon is full" do
      it "generates a full moon SVG" do
        moon = instance_double(
          Moon,
          phase_angle: Astronoby::Angle.from_degrees(0.25),
          age: 15.5
        )
        moon_phase_svg = described_class.new(moon)

        output = moon_phase_svg.draw.gsub(/\s+/, " ").strip

        expected = <<SVG
          <svg
            width="400"
            height="400"
            viewBox="0 0 400 400"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <clipPath>
                <circle
                  cx="200.0"
                  cy="200.0"
                  r="179.0"/>
              </clipPath>
            </defs>
            <circle
              cx="200.0"
              cy="200.0"
              r="179.0"
              fill="#faf8f0"
              stroke="#666"
              stroke-width="2"
            />
          </svg>
SVG
          .gsub(/\s+/, " ")
          .strip

        expect(output).to eq(expected)
      end
    end

    context "when the moon is new" do
      it "generates a new moon SVG" do
        moon = instance_double(
          Moon,
          phase_angle: Astronoby::Angle.from_degrees(179.5),
          age: 29.6
        )
        moon_phase_svg = described_class.new(moon)

        output = moon_phase_svg.draw.gsub(/\s+/, " ").strip

        expected = <<SVG
          <svg
            width="400"
            height="400"
            viewBox="0 0 400 400"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <clipPath>
                <circle
                  cx="200.0"
                  cy="200.0"
                  r="179.0"/>
              </clipPath>
            </defs>
            <circle
              cx="200.0"
              cy="200.0"
              r="179.0"
              fill="#faf8f0"
              stroke="#666"
              stroke-width="2"
            />
            <path
              d="M 21.0,200.0 a 179.0,179.0 0 1,0 358.0,0 a 179.0,179.0 0 1,0 -358.0,0"
              fill="#1a1a1a"
            />
          </svg>
SVG
          .gsub(/\s+/, " ")
          .strip

        expect(output).to eq(expected)
      end
    end

    context "when the moon is wanning gibbous" do
      it "generates a wanning gibbous SVG" do
        moon = instance_double(
          Moon,
          phase_angle: Astronoby::Angle.from_degrees(30),
          age: 17.7
        )
        moon_phase_svg = described_class.new(moon)

        output = moon_phase_svg.draw.gsub(/\s+/, " ").strip

        expected = <<SVG
          <svg
            width="400"
            height="400"
            viewBox="0 0 400 400"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <clipPath>
                <circle cx="200.0" cy="200.0" r="179.0"/>
              </clipPath>
            </defs>
            <circle
              cx="200.0"
              cy="200.0"
              r="179.0"
              fill="#faf8f0"
              stroke="#666"
              stroke-width="2"
            />
            <path
              d="M 200.0 21.0 A 179.0 179.0 0 0 1 200.0 379.0 A 155.01854727741454 179.0 0 0 0 200.0 21.0"
              fill="#1a1a1a"
            />
         </svg>
SVG
          .gsub(/\s+/, " ")
          .strip

        expect(output).to eq(expected)
      end
    end
  end
end
