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

    it "nests its sections directly under the page heading" do
      travel_to Time.utc(2025, 8, 30) do
        get moon_path

        levels = response.body.scan(/<h([1-6])[\s>]/).flatten.map(&:to_i)

        expect(levels.uniq.sort).to eq([1, 2])
      end
    end

    it "titles the page before the site name" do
      travel_to Time.utc(2025, 8, 30) do
        get moon_path

        expect(response.body).to include(
          "<title>Moon phase tonight, rise and set times • Caelus</title>"
        )
      end
    end

    it "keeps the site name in the on-page heading" do
      travel_to Time.utc(2025, 8, 30) do
        get moon_path

        expect(response.body).to include("✨ Caelus • Moon")
      end
    end

    it "describes the page for search engines" do
      travel_to Time.utc(2025, 8, 30) do
        get moon_path

        expect(response.body).to include(
          ERB::Util.html_escape(I18n.t("moon.show.meta_description"))
        )
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

    context "with a time far from now" do
      it "returns a successful response" do
        travel_to Time.utc(2025, 8, 30) do
          post cookie_consent_path
          patch time_path, params: {time: "1900-01-01T00:00:00"}

          get moon_path

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
