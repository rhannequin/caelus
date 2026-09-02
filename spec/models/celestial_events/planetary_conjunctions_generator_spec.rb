require "rails_helper"

RSpec.describe CelestialEvents::PlanetaryConjunctionsGenerator, type: :model do
  describe "#generate" do
    it "records both planets of the pairing" do
      start_date = Time.utc(2026, 11, 1)
      end_date = Time.utc(2026, 12, 1)

      CelestialEvents::PlanetaryConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      event = CelestialEvent.chronological.first

      expect(event.primary_body).to eq("Mars")
      expect(event.secondary_body).to eq("Jupiter")
    end

    it "skips a pairing that is too far apart to look close" do
      start_date = Time.utc(2026, 2, 1)
      end_date = Time.utc(2026, 2, 20)

      CelestialEvents::PlanetaryConjunctionsGenerator
        .new(start_date, end_date)
        .generate

      expect(CelestialEvent.count).to eq(0)
    end
  end
end
