# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeepSkyHelper, type: :helper do
  describe "#near_moon?" do
    it "is false when the Moon is below the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 1, 15))
      position = DeepSkyObjectsCatalog.find_by_designation("M45").at(
        Time.utc(2026, 1, 15, 23),
        observer: observer,
        night: night
      )

      expect(helper.near_moon?(position)).to be false
    end

    it "is true when the Moon sits within the proximity limit" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 9, 30))
      position = DeepSkyObjectsCatalog.find_by_designation("M45").at(
        Time.utc(2026, 9, 30, 23),
        observer: observer,
        night: night
      )

      expect(position.moon_separation)
        .to be <= described_class::MOON_PROXIMITY_LIMIT
      expect(helper.near_moon?(position)).to be true
    end

    it "is false when the Moon is elsewhere in the sky" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 8, 27))
      position = DeepSkyObjectsCatalog.find_by_designation("M31").at(
        Time.utc(2026, 8, 27, 23),
        observer: observer,
        night: night
      )

      expect(helper.near_moon?(position)).to be false
    end
  end

  describe "#deep_sky_look_for" do
    it "returns the observing note for an object that has one" do
      expect(helper.deep_sky_look_for(DeepSkyObjectsCatalog.find_by_designation("M104")))
        .to include("dust lane")
    end

    it "returns nil for an object without a note" do
      expect(helper.deep_sky_look_for(DeepSkyObjectsCatalog.find_by_designation("M73")))
        .to be_nil
    end
  end

  describe "#apparent_size" do
    it "gives one dimension for a circular object" do
      expect(helper.apparent_size(DeepSkyObjectsCatalog.find_by_designation("M13")))
        .to eq("20′")
    end

    it "gives both axes for an elongated object" do
      expect(helper.apparent_size(DeepSkyObjectsCatalog.find_by_designation("M104")))
        .to eq("8.7′ × 3.5′")
    end

    it "drops the decimal when a size is a whole number of arcminutes" do
      expect(helper.apparent_size(DeepSkyObjectsCatalog.find_by_designation("M1")))
        .to eq("6′ × 4′")
    end
  end

  describe "#surface_brightness_label" do
    it "labels the surface brightness of a diffuse object" do
      expect(helper.surface_brightness_label(DeepSkyObjectsCatalog.find_by_designation("M33")))
        .to match(/23\.0 mag\/arcsec/)
    end

    it "is nil for a star cluster" do
      expect(helper.surface_brightness_label(DeepSkyObjectsCatalog.find_by_designation("M45")))
        .to be_nil
    end
  end
end
