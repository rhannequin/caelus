require "rails_helper"

RSpec.describe CelestialEvents::MoonPlanetConjunctionsGenerator, type: :model do
  describe "#generate" do
    it "creates an event for each naked-eye planet the Moon passes" do
      start_date = Time.utc(2026, 9, 1)
      end_date = Time.utc(2027, 6, 1)

      CelestialEvents::MoonPlanetConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.distinct.pluck(:primary_body))
        .to match_array(
          CelestialEvents::MoonPlanetConjunctionsGenerator::PLANETS
        )
    end

    it "skips a pairing whose planet is too faint to be a sight" do
      start_date = Time.utc(2026, 9, 1)
      end_date = Time.utc(2026, 11, 1)

      CelestialEvents::MoonPlanetConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.where(primary_body: "Mars")).not_to exist
      expect(CelestialEvent.where(primary_body: "Jupiter")).to exist
    end

    it "names the planet rather than the Moon, which the kind implies" do
      start_date = Time.utc(2026, 10, 1)
      end_date = Time.utc(2026, 10, 20)

      CelestialEvents::MoonPlanetConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      events = CelestialEvent.all

      expect(events.pluck(:kind).uniq)
        .to eq([CelestialEvent::MOON_PLANET_CONJUNCTION])
      expect(events.pluck(:primary_body)).to all(
        be_in(CelestialEvents::MoonPlanetConjunctionsGenerator::PLANETS)
      )
      expect(events.pluck(:secondary_body).uniq).to eq([nil])
    end

    it "skips a pairing that is lost in the Sun" do
      start_date = Time.utc(2026, 1, 14)
      end_date = Time.utc(2026, 1, 22)

      CelestialEvents::MoonPlanetConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.count).to eq(0)
    end
  end
end
