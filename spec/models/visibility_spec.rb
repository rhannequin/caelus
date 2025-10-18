# frozen_string_literal: true

require "rails_helper"

RSpec.describe Visibility, type: :model do
  describe "#visible?" do
    context "when it rises early in the night" do
      it "returns true" do
        date = Date.new(2025, 12, 1)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8),
          longitude: Astronoby::Angle.from_degrees(2.1)
        )
        visibility = described_class.new(
          body: Jupiter,
          observer: observer,
          date: date
        )

        expect(visibility.visible?).to be true
      end
    end

    context "when it sets early in the night" do
      it "returns true" do
        date = Date.new(2025, 2, 1)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8),
          longitude: Astronoby::Angle.from_degrees(2.1)
        )
        visibility = described_class.new(
          body: Neptune,
          observer: observer,
          date: date
        )

        expect(visibility.visible?).to be true
      end
    end

    context "when it rises late in the night" do
      it "returns true" do
        date = Date.new(2025, 8, 25)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8),
          longitude: Astronoby::Angle.from_degrees(2.1)
        )
        visibility = described_class.new(
          body: Jupiter,
          observer: observer,
          date: date
        )

        expect(visibility.visible?).to be true
      end
    end

    context "when it sets late in the night" do
      it "returns true" do
        date = Date.new(2025, 1, 25)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8),
          longitude: Astronoby::Angle.from_degrees(2.1)
        )
        visibility = described_class.new(
          body: Jupiter,
          observer: observer,
          date: date
        )

        expect(visibility.visible?).to be true
      end
    end

    context "when it is not up during the night" do
      it "returns false" do
        date = Date.new(2025, 12, 1)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8),
          longitude: Astronoby::Angle.from_degrees(2.1)
        )
        visibility = described_class.new(
          body: Mars,
          observer: observer,
          date: date
        )

        expect(visibility.visible?).to be false
      end
    end
  end

  context "when the body is Mercury or Venus" do
    it "uses civil twilight for the night boundaries" do
      date = Date.new(2025, 1, 1)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.1)
      )
      visibility = described_class.new(
        body: Mercury,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be true

      date = Date.new(2025, 2, 7)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.1)
      )
      visibility = described_class.new(
        body: Mercury,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be false

      date = Date.new(2025, 6, 1)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.1)
      )
      visibility = described_class.new(
        body: Venus,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be true

      date = Date.new(2025, 12, 31)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.1)
      )
      visibility = described_class.new(
        body: Venus,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be false
    end
  end

  context "when the body is a deep-sky object" do
    it "uses astronomical twilight for the night boundaries" do
      date = Date.new(2025, 3, 15)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(34.0),
        longitude: Astronoby::Angle.from_degrees(-118.0)
      )
      messier_object = MessierObject.new(
        j2000_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.zero,
          declination: Astronoby::Angle.zero
        )
      )
      visibility = described_class.new(
        body: messier_object,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be true
    end
  end

  context "when there's no twilight" do
    it "returns false" do
      date = Date.new(2025, 6, 20)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(80),
        longitude: Astronoby::Angle.from_degrees(0)
      )
      visibility = described_class.new(
        body: Moon,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be false
    end
  end

  context "when the body does not rise or set" do
    it "returns false" do
      date = Date.new(2025, 6, 20)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(80),
        longitude: Astronoby::Angle.from_degrees(0)
      )
      visibility = described_class.new(
        body: Mars,
        observer: observer,
        date: date
      )

      expect(visibility.visible?).to be false
    end
  end
end
