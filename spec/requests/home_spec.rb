# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomeController, type: :request do
  describe "GET /" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get root_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "canonicalises to the path without query parameters" do
      travel_to Time.utc(2025, 8, 30) do
        get root_path, params: {utm_source: "newsletter"}

        expect(response.body).to include(
          '<link rel="canonical" href="http://www.example.com/">'
        )
      end
    end

    context "with a very high latitude location" do
      it "handles edge cases gracefully a returns a successful response" do
        travel_to Time.utc(2025, 8, 30) do
          post cookie_consent_path
          patch location_path,
            params: {latitude: "80.0", longitude: "0.0"}

          get root_path

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when the night never gets dark" do
      it "says so instead of listing deep-sky objects" do
        travel_to Time.utc(2026, 6, 21, 12) do
          post cookie_consent_path
          patch location_path,
            params: {latitude: "69.65", longitude: "18.96"}

          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(
            I18n.t("home.deep_sky_objects.night.none")
          )
        end
      end
    end

    context "when darkness lasts the whole day" do
      it "says so instead of showing an empty time range" do
        travel_to Time.utc(2026, 12, 21, 12) do
          post cookie_consent_path
          patch location_path, params: {latitude: "88.0", longitude: "0.0"}

          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(
            I18n.t("home.deep_sky_objects.night.all_day")
          )
        end
      end
    end

    context "when the night only reaches nautical twilight" do
      it "says the sky never gets fully dark and still lists objects" do
        travel_to Time.utc(2026, 6, 21, 12) do
          post cookie_consent_path
          patch location_path,
            params: {latitude: "48.85", longitude: "2.35"}

          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Never fully dark tonight")
        end
      end
    end

    context "with a time far from now" do
      it "returns a successful response" do
        travel_to Time.utc(2025, 8, 30) do
          post cookie_consent_path
          patch time_path, params: {time: "1900-01-01T00:00:00"}

          get root_path

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
