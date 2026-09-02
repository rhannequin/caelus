# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sitemap do
  describe "#paths" do
    it "lists the landing pages" do
      sitemap = Sitemap.new(lunar_eclipse_years: 2026..2026)

      expect(sitemap.paths).to include(
        "/",
        "/almanac",
        "/moon",
        "/sun",
        "/lunar_eclipses",
        "/privacy_policy"
      )
    end

    it "lists one page per lunar eclipse year" do
      travel_to Time.utc(2026, 9, 2) do
        sitemap = Sitemap.new(lunar_eclipse_years: 2024..2028)

        expect(sitemap.paths).to include(
          "/lunar_eclipses?year=2024",
          "/lunar_eclipses?year=2025",
          "/lunar_eclipses?year=2027",
          "/lunar_eclipses?year=2028"
        )
      end
    end

    it "omits the current year, already covered by the bare path" do
      travel_to Time.utc(2026, 9, 2) do
        sitemap = Sitemap.new(lunar_eclipse_years: 2024..2028)

        expect(sitemap.paths).not_to include("/lunar_eclipses?year=2026")
      end
    end

    it "does not repeat a path" do
      sitemap = Sitemap.new(
        lunar_eclipse_years: LunarEclipsesController::SUPPORTED_YEARS
      )

      expect(sitemap.paths).to eq(sitemap.paths.uniq)
    end
  end
end
