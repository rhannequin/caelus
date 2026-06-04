# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimeController, type: :request do
  describe "PATCH time" do
    context "when cookie consent is given" do
      it "updates the observer's time, stores it in UTC" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: "2025-12-01T20:49:51"}
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:time]).to eq("2025-12-01T19:49:51Z")
      end

      it "ignores invalid time value" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: "Dec 1 25 8:49 PM"}
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:time]).to be_nil
      end

      it "ignores blank time value" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: ""}
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:time]).to be_nil
      end

      it "ignores values out of range" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: "3000-01-01T00:00:00"}
        )
        jar = response.request.cookie_jar

        expect(jar.signed[:time]).to be_nil
      end

      it "redirects to the root path after updating when no referer" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: "2025-12-01T20:49:51"}
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end

      it "redirects back to the referring page after updating" do
        post cookie_consent_path

        patch(
          time_path,
          params: {time: "2025-12-01T20:49:51"},
          headers: {"HTTP_REFERER" => moon_path}
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(moon_path)
      end

      it "redirects back to referring page when cookie consent is not given" do
        patch(
          time_path,
          params: {time: "2025-12-01T20:49:51"},
          headers: {"HTTP_REFERER" => sun_path}
        )

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(sun_path)
      end
    end
  end

  describe "DELETE time" do
    context "when cookie consent is given" do
      it "clears the stored time so it follows real-time again" do
        post cookie_consent_path
        patch(time_path, params: {time: "2025-12-01T20:49:51"})

        delete time_path
        jar = response.request.cookie_jar

        expect(jar.signed[:time]).to be_nil
      end

      it "redirects to the root path when no referer" do
        post cookie_consent_path

        delete time_path

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end

      it "redirects back to the referring page" do
        post cookie_consent_path

        delete(time_path, headers: {"HTTP_REFERER" => moon_path})

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(moon_path)
      end
    end

    context "when cookie consent is not given" do
      it "redirects back without changing anything" do
        delete(time_path, headers: {"HTTP_REFERER" => sun_path})

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(sun_path)
      end
    end
  end
end
