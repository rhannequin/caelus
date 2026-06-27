# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoonPhaseComponent, type: :component do
  def render_moon(phase_angle_degrees:, age:, **options)
    moon = instance_double(
      Moon,
      phase_angle: Astronoby::Angle.from_degrees(phase_angle_degrees),
      age: age
    )
    render_inline(described_class.new(moon: moon, **options))
  end

  it "renders a 2x viewBox and the moon base circle" do
    result = render_moon(phase_angle_degrees: 125.5, age: 4.7, size: 200)

    expect(result.css("svg").attribute("viewBox").value).to eq("0 0 400 400")
    expect(result.css("circle").last["r"]).to eq("179.0")
    expect(result.css("circle").last["fill"]).to eq("#faf8f0")
  end

  context "when the moon is a waxing crescent" do
    it "draws the terminator shadow path" do
      result = render_moon(phase_angle_degrees: 125.5, age: 4.7)

      paths = result.css("path")
      expect(paths.size).to eq(1)
      expect(paths.first["d"]).to eq(
        "M 200.0 21.0 A 179.0 179.0 0 0 0 200.0 379.0 " \
          "A 103.94582907225822 179.0 0 1 0 200.0 21.0"
      )
      expect(paths.first["fill"]).to eq("#1a1a1a")
    end
  end

  context "when the moon is full" do
    it "draws no shadow path" do
      result = render_moon(phase_angle_degrees: 0.25, age: 15.5)

      expect(result.css("path")).to be_empty
    end
  end

  context "when the moon is new" do
    it "draws a full-disc shadow path" do
      result = render_moon(phase_angle_degrees: 179.5, age: 29.6)

      expect(result.css("path").first["d"]).to eq(
        "M 21.0,200.0 a 179.0,179.0 0 1,0 358.0,0 " \
          "a 179.0,179.0 0 1,0 -358.0,0"
      )
    end
  end

  context "when the moon is waning gibbous" do
    it "draws the terminator shadow path on the opposite hemisphere" do
      result = render_moon(phase_angle_degrees: 30, age: 17.7)

      expect(result.css("path").first["d"]).to eq(
        "M 200.0 21.0 A 179.0 179.0 0 0 1 200.0 379.0 " \
          "A 155.01854727741454 179.0 0 0 0 200.0 21.0"
      )
    end
  end
end
