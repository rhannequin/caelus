# frozen_string_literal: true

require "rails_helper"

RSpec.describe CookieConsentController, type: :request do
  describe "POST cookie_consent" do
    it "sets the cookie consent cookie" do
      post cookie_consent_path
      jar = response.request.cookie_jar

      expect(jar.signed[:cookie_consent]).to eq("true")
    end

    it "redirects to the root path after creating when no referer" do
      post cookie_consent_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "redirects back to the referring page after creating" do
      post cookie_consent_path, headers: {"HTTP_REFERER" => moon_path}

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(moon_path)
    end
  end

  describe "DELETE /cookie_consent" do
    it "clears the observer's location cookies" do
      post cookie_consent_path
      patch(
        location_path,
        params: {
          latitude: "34.0567",
          longitude: "-118.2543",
          utc_offset: "-08:00"
        }
      )
      jar = response.request.cookie_jar

      expect(jar.signed[:latitude]).to eq("34.0567")
      expect(jar.signed[:longitude]).to eq("-118.2543")
      expect(jar.signed[:utc_offset]).to eq("-08:00")

      delete cookie_consent_path
      jar = response.request.cookie_jar

      expect(jar.signed[:latitude]).to be_nil
      expect(jar.signed[:longitude]).to be_nil
      expect(jar.signed[:utc_offset]).to be_nil
    end

    it "redirects to the root path after deleting when no referer" do
      delete cookie_consent_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "redirects back to the referring page after deleting" do
      delete cookie_consent_path, headers: {"HTTP_REFERER" => sun_path}

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(sun_path)
    end
  end
end
