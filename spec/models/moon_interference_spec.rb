# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoonInterference do
  describe "#percentage" do
    it "returns the percentage of nighttime the moon is above the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 1)
      )

      # Night from 18:46 to 05:14 (628 minutes)
      # Moon above the horizon from 15:47 to 22:14
      # Moon above the horizon during night from 18:46 to 22:14 (208 minutes)
      # Percentage: 208 * 100 / 628 = 33%
      expect(moon_interference.percentage).to eq(33)
    end

    context "when there is moonset available (sets early next day)" do
      it "uses the next day's moonset time" do
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(51.5074),
          longitude: Astronoby::Angle.from_degrees(-0.1278)
        )

        moon_interference = described_class.new(
          observer: observer,
          date: Date.new(2025, 9, 3)
        )

        # Night from 18:41 to 05:18 (636 minutes)
        # Moon above the horizon from 17:15 to 00:28 (next day)
        # Moon above the horizon during night from 18:41 to 00:28 (346 minutes)
        # Percentage: 346 * 100 / 636 = 54%
        expect(moon_interference.percentage).to eq(54)
      end
    end

    context "when there is no moonrise or moonset during the night" do
      it "returns 0" do
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(70),
          longitude: Astronoby::Angle.from_degrees(0)
        )

        moon_interference = described_class.new(
          observer: observer,
          date: Date.new(2025, 8, 19)
        )

        expect(moon_interference.percentage).to eq(0)
      end
    end
  end

  describe "#interference" do
    it "returns 'none' for 0%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 21)
      )

      expect(moon_interference.interference).to eq(:none)
    end

    it "returns 'low' for 15%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 19)
      )

      expect(moon_interference.interference).to eq(:low)
    end

    it "returns 'moderate' for 38%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 17)
      )

      expect(moon_interference.interference).to eq(:moderate)
    end

    it "returns 'high' for 68%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 4)
      )

      expect(moon_interference.interference).to eq(:high)
    end

    it "returns 'extreme' for 90%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 11)
      )

      expect(moon_interference.interference).to eq(:extreme)
    end

    it "returns 'full' for 100%" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(51.5074),
        longitude: Astronoby::Angle.from_degrees(-0.1278)
      )

      moon_interference = described_class.new(
        observer: observer,
        date: Date.new(2025, 9, 7)
      )

      expect(moon_interference.interference).to eq(:full)
    end
  end
end
