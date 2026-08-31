# frozen_string_literal: true

require "rails_helper"

RSpec.describe AlmanacController, type: :request do
  describe "GET /almanac" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get almanac_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "lists the events falling within the lookahead window" do
      travel_to Time.utc(2026, 8, 30) do
        create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars",
          peak: Time.utc(2026, 11, 4, 21, 30)
        )
        create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Saturn",
          peak: Time.utc(2028, 3, 1)
        )

        get almanac_path

        expect(response.body).to include("Mars at opposition")
        expect(response.body).to include("November 2026")
        expect(response.body).not_to include("Saturn at opposition")
      end
    end

    it "renders an empty state when no event is upcoming" do
      travel_to Time.utc(2026, 8, 30) do
        create(:celestial_event, peak: Time.utc(2020, 1, 1))

        get almanac_path

        expect(response.body).to include("No events on the horizon")
      end
    end

    it "tracks the page view" do
      travel_to Time.utc(2026, 8, 30) do
        expect(Appsignal).to(
          receive(:increment_counter)
            .with("page_view", 1, page: "almanac")
        )

        get almanac_path
      end
    end
  end
end
