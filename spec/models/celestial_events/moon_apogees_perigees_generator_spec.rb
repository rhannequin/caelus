require "rails_helper"

RSpec.describe CelestialEvents::MoonApogeesPerigeesGenerator, type: :model do
  describe "#generate" do
    it "creates celestial events for apogee and perigee" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::MoonApogeesPerigeesGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change(CelestialEvent, :count)
        .by(27)
      expect(CelestialEvent.where(kind: CelestialEvent::MOON_APOGEE).count)
        .to be 13
      expect(CelestialEvent.where(kind: CelestialEvent::MOON_PERIGEE).count)
        .to be 14
    end
  end
end
