require "rails_helper"

RSpec.describe CelestialEvents::LunarEclipsesGenerator, type: :model do
  describe "#generate" do
    it "creates celestial events for lunar eclipses" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::LunarEclipsesGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change { CelestialEvent.count }.from(0).to(2)
    end

    it "creates lunar eclipse kind of celestial events" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::LunarEclipsesGenerator
        .new(start_date, end_date)

      generator.generate

      expect(CelestialEvent.distinct(:kind).pluck(:kind))
        .to contain_exactly(CelestialEvent::LUNAR_ECLIPSE)
    end

    it "sets the peak_tt of the celestial events to relevant values" do
      start_date = Time.utc(2026, 1, 1)
      start_tt = Astronoby::Instant.from_time(start_date).tt
      end_date = Time.utc(2027, 1, 1)
      end_tt = Astronoby::Instant.from_time(end_date).tt

      generator = CelestialEvents::LunarEclipsesGenerator
        .new(start_date, end_date)

      generator.generate

      expect(CelestialEvent.pluck(:peak_tt))
        .to all(be >= start_tt)
        .and all(be <= end_tt)
    end
  end
end
