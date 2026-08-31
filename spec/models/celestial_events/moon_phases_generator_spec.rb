require "rails_helper"

RSpec.describe CelestialEvents::MoonPhasesGenerator, type: :model do
  describe "#generate" do
    it "creates a celestial event for each principal phase of the period" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2026, 4, 1)

      generator = CelestialEvents::MoonPhasesGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change { CelestialEvent.count }.from(0).to(16)
    end

    it "creates the four principal moon phase kinds" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::MoonPhasesGenerator
        .new(start_date, end_date)

      generator.generate

      expect(CelestialEvent.distinct(:kind).pluck(:kind))
        .to contain_exactly(*CelestialEvent::MOON_PHASE_KINDS)
    end

    it "covers in full every month the period touches" do
      start_date = Time.utc(2026, 6, 10)
      end_date = Time.utc(2026, 8, 20)

      generator = CelestialEvents::MoonPhasesGenerator
        .new(start_date, end_date)

      generator.generate

      expect(CelestialEvent.pluck(:peak_at))
        .to all(be_between(Time.utc(2026, 6, 1), Time.utc(2026, 9, 1)))
    end

    it "includes the phases of a partial month that precede the period" do
      start_date = Time.utc(2026, 6, 10)
      end_date = Time.utc(2026, 8, 20)

      generator = CelestialEvents::MoonPhasesGenerator
        .new(start_date, end_date)

      generator.generate

      expect(CelestialEvent.where(peak_at: ...start_date)).to exist
    end

    it "does not create the same phase twice" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::MoonPhasesGenerator
        .new(start_date, end_date)

      generator.generate

      peak_ats = CelestialEvent.pluck(:peak_at)

      expect(peak_ats).to eq(peak_ats.uniq)
    end
  end
end
