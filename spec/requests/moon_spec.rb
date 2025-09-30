# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoonController, type: :request do
  describe "GET /moon" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get moon_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "using an extreme latitude" do
      it "returns a successful response" do
        travel_to Time.utc(2025, 12, 21) do
          post cookie_consent_path
          patch(
            location_path,
            params: {
              latitude: "89",
              longitude: "0"
            }
          )

          get moon_path

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
