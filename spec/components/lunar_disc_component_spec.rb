# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarDiscComponent, type: :component do
  def crater(name, longitude, latitude)
    Lunar::Feature.crater(
      name: name,
      center: Lunar::SurfacePoint.from_degrees(longitude, latitude),
      radius: Astronoby::Angle.from_degrees(6)
    )
  end

  def build_moon(
    phase_angle: 90,
    bright_limb_position_angle: 90,
    axis_position_angle: 0,
    parallactic_angle: 0,
    phase_name: :first_quarter,
    illuminated_fraction: 0.5,
    angular_diameter: 0.5181,
    features: [crater("east", 40, 0), crater("west", -40, 0)]
  )
    disc = Lunar::Disc.new(
      libration: Astronoby::Libration.new(
        longitude: Astronoby::Angle.zero,
        latitude: Astronoby::Angle.zero
      ),
      phase_angle: Astronoby::Angle.from_degrees(phase_angle),
      bright_limb_position_angle:
        Astronoby::Angle.from_degrees(bright_limb_position_angle),
      axis_position_angle: Astronoby::Angle.from_degrees(axis_position_angle),
      parallactic_angle: Astronoby::Angle.from_degrees(parallactic_angle),
      catalog: Lunar::FeatureCatalog.new(features: features)
    )
    instance_double(
      Moon,
      lunar_disc: disc,
      current_phase_name: phase_name,
      illuminated_fraction: illuminated_fraction,
      angular_diameter: Astronoby::Angle.from_degrees(angular_diameter)
    )
  end

  def render_disc(**options)
    render_inline(described_class.new(moon: build_moon(**options)))
  end

  describe "accessibility" do
    it "renders a labelled image referencing its title and description" do
      result = render_disc

      svg = result.css("svg").first
      title = result.css("title").first
      description = result.css("desc").first

      expect(svg["role"]).to eq("img")
      expect(svg["aria-labelledby"].split)
        .to contain_exactly(title["id"], description["id"])
      expect(title.text).to be_present
      expect(description.text).to include("50%")
    end

    it "hides the decorative surface from assistive technology" do
      result = render_disc

      expect(result.css("[clip-path]").first["aria-hidden"]).to eq("true")
    end

    it "states the apparent diameter in the description" do
      result = render_disc(angular_diameter: 0.525)

      expect(result.css("desc").text).to include("31.5′")
    end
  end

  describe "apparent size" do
    it "draws a larger disc for a larger angular diameter" do
      near = render_disc(angular_diameter: 0.55).css("circle").first["r"].to_f
      far = render_disc(angular_diameter: 0.49).css("circle").first["r"].to_f

      expect(near).to be > far
    end
  end

  describe "the surface" do
    it "draws every feature and no shadow at full moon" do
      result = render_disc(phase_angle: 0, illuminated_fraction: 1.0)

      expect(result.css("path.lunar-disc__feature").size).to eq(2)
      expect(result.css("path.lunar-disc__shadow")).to be_empty
    end

    it "covers the whole disc with shadow at new moon" do
      result = render_disc(phase_angle: 180, illuminated_fraction: 0.0)

      expect(result.css("path.lunar-disc__shadow").size).to eq(1)
    end

    it "covers the night side with a shadow at the quarter" do
      result = render_disc(phase_angle: 90, bright_limb_position_angle: 270)

      expect(result.css("path.lunar-disc__shadow").size).to eq(1)
      expect(result.css("path.lunar-disc__feature")).not_to be_empty
    end
  end

  describe "crater rays" do
    it "draws rays as faint, straight strokes" do
      ray = Lunar::Feature.patch(
        name: "tycho_ray",
        kind: :ray,
        outline: [
          Lunar::SurfacePoint.from_degrees(0, 0),
          Lunar::SurfacePoint.from_degrees(2, 18),
          Lunar::SurfacePoint.from_degrees(-2, 18)
        ]
      )

      result = render_disc(
        phase_angle: 0,
        illuminated_fraction: 1.0,
        features: [ray]
      )
      path = result.css("path.lunar-disc__feature").first

      expect(path["fill-opacity"]).to eq("0.22")
      expect(path["d"]).not_to include("C")
    end
  end

  describe "observer orientation" do
    it "rotates the disc by the parallactic angle minus the axis angle" do
      result = render_disc(axis_position_angle: 20, parallactic_angle: 10)

      transform = result.css("g").first["transform"]

      expect(transform).to match(/rotate\(-10(\.0+)? /)
    end
  end
end
