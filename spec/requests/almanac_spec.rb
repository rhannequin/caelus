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
