# frozen_string_literal: true

require "rails_helper"

RSpec.describe ObservingNight, type: :model do
  describe "#darkness" do
    it "reports astronomical darkness when the Sun sets far enough" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 1, 15)
      )

      expect(night.darkness).to eq(:astronomical)
      expect(night).to be_full_darkness
    end

    it "falls back to nautical darkness around the June solstice in Paris" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 6, 21)
      )

      expect(night.darkness).to eq(:nautical)
      expect(night).to be_dark
      expect(night).not_to be_full_darkness
    end

    it "reports no darkness when the Sun stays above civil twilight" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(69.65),
        longitude: Astronoby::Angle.from_degrees(18.96)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 6, 21)
      )

      expect(night.darkness).to eq(:none)
      expect(night).not_to be_dark
      expect(night.range).to be_nil
    end
  end

  describe "#range" do
    it "returns the requested darkness level rather than the deepest one" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 1, 15)
      )

      civil = night.range(darkness: :civil)

      expect(civil.begin).to be < night.range.begin
      expect(civil.end).to be > night.range.end
    end
  end

  describe "#times" do
    it "is empty when the night offers no darkness" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(69.65),
        longitude: Astronoby::Angle.from_degrees(18.96)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 6, 21)
      )

      expect(night.times).to be_empty
    end

    it "samples from dusk to dawn" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 1, 15)
      )

      expect(night.times.first).to eq(night.range.begin)
      expect(night.times.last).to eq(night.range.end)
      expect(night.times).to eq(night.times.sort)
    end
  end

  describe "#moonless_range" do
    it "is nil when a full Moon is up all night" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 8, 27)
      )

      expect(night.moon_illuminated_fraction).to be > 0.98
      expect(night.moonless_range).to be_nil
    end

    it "covers most of the night around new Moon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      night = described_class.new(
        observer: observer,
        date: Date.new(2026, 9, 10)
      )

      moonless = night.moonless_range

      expect(moonless).not_to be_nil
      expect(moonless.end - moonless.begin).to be > night.duration * 0.9
    end
  end
end
