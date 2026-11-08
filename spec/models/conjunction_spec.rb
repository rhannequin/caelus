# frozen_string_literal: true

require "rails_helper"

RSpec.describe Conjunction, type: :model do
  describe "#bodies" do
    it "puts the Moon first when it meets a planet" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.bodies.map(&:class)).to eq([Moon, Saturn])
    end

    it "keeps the stored order when two planets meet" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.bodies.map(&:class)).to eq([Mars, Jupiter])
    end
  end

  describe "#apparent_separation" do
    it "differs from the geocentric separation for the nearby Moon" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)
      shift = conjunction.apparent_separation - conjunction.separation

      expect(shift.degrees.abs).to be > 0.1
    end

    it "matches the geocentric separation for distant planets" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)
      shift = conjunction.apparent_separation - conjunction.separation

      expect(shift.degrees.abs).to be < 0.01
    end
  end

  describe "#apparitions" do
    it "spans the nights either side of the peak for two planets" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.apparitions.size).to be > 1
      expect(conjunction.apparitions.map(&:date))
        .to include(Date.new(2026, 11, 14), Date.new(2026, 11, 17))
    end

    it "marks the night the peak falls into" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)
      peak_nights = conjunction.apparitions.select do |apparition|
        conjunction.peak_night?(apparition)
      end

      expect(peak_nights.map(&:date)).to eq([Date.new(2026, 11, 15)])
    end

    it "keeps a night whose best-placed moment drifts, but which still pairs" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.apparitions.map(&:date))
        .to include(Date.new(2026, 9, 27))
    end

    it "drops nights on which the Moon has wandered off" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.apparitions.map { |a| a.separation.degrees })
        .to all(be < conjunction.separation.degrees + 5)
    end
  end

  describe "#visible?" do
    it "is false when the pair only shares the daytime sky" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Venus",
        peak: Time.utc(2026, 10, 12, 4, 37)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction).not_to be_visible
      expect(conjunction.apparitions).to be_empty
      expect(conjunction.closest_apparition).to be_nil
    end

    it "is true when both bodies clear the horizon after dark" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction).to be_visible
      expect(conjunction.closest_apparition.altitude).to be_positive
    end
  end

  describe "#known_bodies?" do
    it "rejects a stored body it cannot resolve" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Pluto",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction.known_bodies?).to be false
    end
  end

  describe "#peak_observable?" do
    it "is false when the closest approach happens below the horizon" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction).to be_visible
      expect(conjunction).not_to be_peak_observable
      expect(conjunction.closest_apparition.separation)
        .to be > conjunction.separation
    end

    it "is true when the closest approach falls in a dark sky" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction).to be_peak_observable
    end
  end

  describe "#unobservable_reason" do
    it "says the pair drifted when it only clears the horizon too far apart" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Jupiter",
        peak: Time.utc(2027, 6, 9, 9, 35, 20)
      )

      conjunction = described_class.new(celestial_event: event, observer: paris)

      expect(conjunction).not_to be_visible
      expect(conjunction.unobservable_reason).to eq described_class::DRIFTED
    end

    it "blames the midnight sun when no darkness falls" do
      tromso = Observer.new(
        astronoby_observer: Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(69.65),
          longitude: Astronoby::Angle.from_degrees(18.96),
          utc_offset: "+02:00"
        ),
        time_zone: Time.find_zone("Europe/Oslo")
      )
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 6, 21, 12)
      )

      conjunction = described_class.new(
        celestial_event: event,
        observer: tromso
      )

      expect(conjunction.unobservable_reason).to eq described_class::NO_DARKNESS
    end

    it "has a translation for each of possible reason" do
      described_class::UNOBSERVABLE_REASONS.each do |reason|
        expect { I18n.t("conjunctions.observer.not_visible.#{reason}") }
          .not_to raise_error
      end
    end
  end

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
end
