# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessierObjectPosition, type: :model do
  describe "#highest_altitude" do
    it "is nil when no night is given" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      position = MessierCatalog.find_by_number(31).at(
        Time.utc(2026, 1, 15, 22),
        observer: observer
      )

      expect(position.highest_altitude).to be_nil
      expect(position.highest_altitude_time).to be_nil
    end

    it "is nil when the night offers no darkness" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(69.65),
        longitude: Astronoby::Angle.from_degrees(18.96)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 6, 21))

      position = MessierCatalog.find_by_number(13).at(
        Time.utc(2026, 6, 21, 23),
        observer: observer,
        night: night
      )

      expect(position.highest_altitude).to be_nil
    end

    it "reports the highest point reached within the night" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 1, 15))

      position = MessierCatalog.find_by_number(31).at(
        Time.utc(2026, 1, 15, 22),
        observer: observer,
        night: night
      )

      expect(position.highest_altitude.degrees).to be_within(1).of(74)
      expect(night.range).to cover(position.highest_altitude_time)
    end

    it "peaks at transit when the object culminates during the night" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 1, 15))

      position = MessierCatalog.find_by_number(45).at(
        Time.utc(2026, 1, 15, 22),
        observer: observer,
        night: night
      )

      expect(night.range).to cover(position.rts.transit_time)
      expect(position.highest_altitude_time).to eq(position.rts.transit_time)
    end

    it "peaks at dusk when the object culminates before the night starts" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 1, 15))

      position = MessierCatalog.find_by_number(31).at(
        Time.utc(2026, 1, 15, 22),
        observer: observer,
        night: night
      )

      expect(position.rts.transit_time).to be < night.range.begin
      expect(position.highest_altitude_time).to eq(night.range.begin)
    end
  end

  describe "#moon_separation" do
    it "is nil when the Moon is below the horizon at culmination" do
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

      expect(position.moon_separation).to be_nil
    end

    it "is nil when there is no night to observe" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(69.65),
        longitude: Astronoby::Angle.from_degrees(18.96)
      )
      night = ObservingNight.new(observer: observer, date: Date.new(2026, 6, 21))

      position = MessierCatalog.find_by_number(13).at(
        Time.utc(2026, 6, 21, 23),
        observer: observer,
        night: night
      )

      expect(position.moon_separation).to be_nil
    end

    it "measures how close the Moon is when the object is highest" do
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

      expect(position.moon_separation.degrees).to be_within(1).of(5.4)
    end
  end
end
