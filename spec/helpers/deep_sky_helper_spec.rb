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
      position = MessierCatalog.find_by_number(45).at(
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
      position = MessierCatalog.find_by_number(45).at(
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
      position = MessierCatalog.find_by_number(31).at(
        Time.utc(2026, 8, 27, 23),
        observer: observer,
        night: night
      )

      expect(helper.near_moon?(position)).to be false
    end
  end

  describe "#messier_look_for" do
    it "returns the observing note for an object that has one" do
      expect(helper.messier_look_for(MessierCatalog.find_by_number(104)))
        .to include("dust lane")
    end

    it "returns nil for an object without a note" do
      expect(helper.messier_look_for(MessierCatalog.find_by_number(73)))
        .to be_nil
    end
  end
end
