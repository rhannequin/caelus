# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConjunctionHelper, type: :helper do
  describe "#conjunction_separation" do
    it "switches to arcminutes below a degree" do
      angle = Astronoby::Angle.from_degrees(0.25)

      expect(helper.conjunction_separation(angle)).to eq("15.0′")
    end

    it "stays in degrees above a degree" do
      angle = Astronoby::Angle.from_degrees(3.5)

      expect(helper.conjunction_separation(angle)).to eq("3.50°")
    end
  end

  describe "#conjunction_magnitude" do
    it "signs a positive magnitude, as astronomers write it" do
      expect(helper.conjunction_magnitude(0.56)).to eq("+0.56")
    end

    it "leaves a negative magnitude alone" do
      expect(helper.conjunction_magnitude(-2.09)).to eq("-2.09")
    end
  end

  describe "#conjunction_distance" do
    it "uses kilometres for something as near as the Moon" do
      distance = Astronoby::Distance.from_km(377_287)

      expect(helper.conjunction_distance(distance))
        .to eq("377\u202F287\u00A0km")
    end

    it "uses astronomical units for a planet" do
      distance = Astronoby::Distance.from_astronomical_units(5.266)

      expect(helper.conjunction_distance(distance)).to eq("5.266\u00A0AU")
    end
  end

  describe "#conjunction_angular_diameter" do
    it "uses arcminutes for a disc as wide as the Moon" do
      angle = Astronoby::Angle.from_degrees(0.528)

      expect(helper.conjunction_angular_diameter(angle)).to eq("31.7′")
    end

    it "uses arcseconds for a planet" do
      angle = Astronoby::Angle.from_degrees(0.0103)

      expect(helper.conjunction_angular_diameter(angle)).to eq("37″")
    end
  end

  describe "#conjunction_shows_illumination?" do
    def paris
      Observer.new(
        astronoby_observer: Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.85),
          longitude: Astronoby::Angle.from_degrees(2.35),
          utc_offset: "+01:00"
        ),
        time_zone: Time.find_zone("Europe/Paris")
      )
    end

    it "always reports the Moon, whose phase is the point" do
      moon = Moon.new(observer: paris, time: Time.utc(2026, 9, 27, 6, 36))

      expect(helper.conjunction_shows_illumination?(moon)).to be true
    end

    it "skips a planet that shows a full face" do
      jupiter = Jupiter.new(observer: paris, time: Time.utc(2026, 11, 16, 2, 4))

      expect(jupiter.illuminated_percentage).to be > 99
      expect(helper.conjunction_shows_illumination?(jupiter)).to be false
    end

    it "reports a planet caught in a phase" do
      mars = Mars.new(observer: paris, time: Time.utc(2026, 11, 16, 2, 4))

      expect(helper.conjunction_shows_illumination?(mars)).to be true
    end
  end

  describe "#conjunction_relative_direction" do
    it "reads a position angle as a compass point on the sky" do
      expect(
        helper.conjunction_relative_direction(Astronoby::Angle.from_degrees(0))
      ).to eq("N")
      expect(
        helper.conjunction_relative_direction(Astronoby::Angle.from_degrees(90))
      ).to eq("E")
      expect(
        helper.conjunction_relative_direction(
          Astronoby::Angle.from_degrees(197)
        )
      ).to eq("S")
    end
  end
end
