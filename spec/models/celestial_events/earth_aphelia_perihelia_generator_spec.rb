require "rails_helper"

RSpec.describe CelestialEvents::EarthApheliaPeriheliaGenerator, type: :model do
  describe "#generate" do
    it "creates celestial events for aphelion and perihelion" do
      start_date = Time.utc(2025, 12, 1)
      end_date = Time.utc(2027, 12, 1)

      generator = CelestialEvents::EarthApheliaPeriheliaGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change(CelestialEvent, :count)
        .by(4)
      expect(CelestialEvent.of_kind(CelestialEvent::EARTH_APHELION).count)
        .to be 2
      expect(CelestialEvent.of_kind(CelestialEvent::EARTH_PERIHELION).count)
        .to be 2
    end

    it "misses an apsis within a few days of the start of the period" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      CelestialEvents::EarthApheliaPeriheliaGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.of_kind(CelestialEvent::EARTH_PERIHELION))
        .not_to exist
    end
  end
end
