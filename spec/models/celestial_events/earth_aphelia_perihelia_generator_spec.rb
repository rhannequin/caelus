require "rails_helper"

RSpec.describe CelestialEvents::EarthApheliaPeriheliaGenerator, type: :model do
  describe "#generate" do
    it "creates celestial events for aphelion and perihelion" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2028, 1, 1)

      generator = CelestialEvents::EarthApheliaPeriheliaGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change(CelestialEvent, :count)
        .by(3)
      expect(CelestialEvent.where(kind: CelestialEvent::EARTH_APHELION).count)
        .to be 2
      expect(CelestialEvent.where(kind: CelestialEvent::EARTH_PERIHELION).count)
        .to be 1
    end
  end
end
