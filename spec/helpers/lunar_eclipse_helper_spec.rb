# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipseHelper, type: :helper do
  describe "#lunar_eclipses_canonical_url" do
    it "drops the year parameter for the current year" do
      travel_to Time.utc(2026, 8, 25) do
        result = helper.lunar_eclipses_canonical_url(2026)

        expect(result).to eq("http://test.host/lunar_eclipses")
      end
    end

    it "keeps the year parameter for another year" do
      travel_to Time.utc(2026, 8, 25) do
        result = helper.lunar_eclipses_canonical_url(2027)

        expect(result).to eq("http://test.host/lunar_eclipses?year=2027")
      end
    end
  end
end
