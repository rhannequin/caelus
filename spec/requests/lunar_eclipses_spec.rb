# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipsesController, type: :request do
  describe "GET /lunar_eclipses" do
    it "returns a successful response" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "tracks the page view" do
      travel_to Time.utc(2026, 8, 25) do
        expect(Appsignal).to(
          receive(:increment_counter)
            .with("page_view", 1, page: "lunar_eclipses")
        )

        get lunar_eclipses_path
      end
    end
  end
end
