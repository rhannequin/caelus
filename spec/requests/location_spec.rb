# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationController, type: :request do
  describe "GET location/edit" do
    it "keeps the page out of search results" do
      travel_to Time.utc(2026, 8, 25) do
        get edit_location_path

        expect(response.headers["X-Robots-Tag"]).to eq("noindex")
      end
    end
  end

  describe "PATCH location" do
    context "when cookie consent is given" do
      it "updates the observer's location" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543",
            time_zone: "America/Los_Angeles"
          }
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:latitude]).to eq(34.0567)
        expect(jar.signed[:longitude]).to eq(-118.2543)
        expect(jar.signed[:time_zone]).to eq("America/Los_Angeles")
      end

      it "ignores invalid latitude value" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "100.0000",
            longitude: "-118.2543",
            time_zone: "America/Los_Angeles"
          }
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:latitude]).to be_nil
        expect(jar.signed[:longitude]).to be_nil
      end

      it "ignores invalid longitude value" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-200.0000",
            time_zone: "America/Los_Angeles"
          }
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:latitude]).to be_nil
        expect(jar.signed[:longitude]).to be_nil
      end

      it "redirects to the root path after updating when no referer" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543",
            time_zone: "America/Los_Angeles"
          }
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end

      it "redirects back to the referring page after updating" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543",
            time_zone: "America/Los_Angeles"
          },
          headers: {"HTTP_REFERER" => moon_path}
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(moon_path)
      end

      it "rejects invalid time zones" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543",
            time_zone: "Los"
          }
        )
        jar = response.request.cookie_jar

        expect(response).to have_http_status(:found)
        expect(jar.signed[:latitude]).to eq(34.0567)
        expect(jar.signed[:longitude]).to eq(-118.2543)
        expect(jar.signed[:time_zone]).to be_nil
        expect(response).to redirect_to(root_path)
      end

      it "works without time_zone parameter" do
        post cookie_consent_path

        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543"
          }
        )
        jar = response.request.cookie_jar

        expect(response).to have_http_status(:found)
        expect(jar.signed[:latitude]).to eq(34.0567)
        expect(jar.signed[:longitude]).to eq(-118.2543)
        expect(jar.signed[:time_zone]).to be_nil
        expect(response).to redirect_to(root_path)
      end

      it "redirects back to referring page when cookie consent is not given" do
        patch(
          location_path,
          params: {
            latitude: "34.0567",
            longitude: "-118.2543",
            time_zone: "America/Los_Angeles"
          },
          headers: {"HTTP_REFERER" => sun_path}
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(sun_path)
      end
    end
  end
end
