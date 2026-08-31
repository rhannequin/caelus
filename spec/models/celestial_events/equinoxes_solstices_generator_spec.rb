require "rails_helper"

RSpec.describe CelestialEvents::EquinoxesSolsticesGenerator, type: :model do
  describe "#generate" do
    it "creates the four season events of each year" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 12, 31)
      generator = CelestialEvents::EquinoxesSolsticesGenerator
        .new(start_date, end_date)

      expect { generator.generate }
        .to change { CelestialEvent.count }.from(0).to(8)
    end

    it "creates each season kind of celestial event" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      CelestialEvents::EquinoxesSolsticesGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.chronological.pluck(:kind))
        .to eq(CelestialEvent::SEASON_KINDS)
    end

    it "keeps the events within the requested period" do
      start_date = Time.utc(2026, 5, 1)
      end_date = Time.utc(2026, 10, 1)

      CelestialEvents::EquinoxesSolsticesGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.pluck(:peak_at))
        .to all(be_between(start_date, end_date))
    end

    it "covers a period spanning the turn of a year" do
      start_date = Time.utc(2026, 11, 1)
      end_date = Time.utc(2027, 4, 1)

      CelestialEvents::EquinoxesSolsticesGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.chronological.pluck(:kind)).to eq(
        [CelestialEvent::DECEMBER_SOLSTICE, CelestialEvent::MARCH_EQUINOX]
      )
    end
  end
end
