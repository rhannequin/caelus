# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrivacyPolicyController, type: :request do
  describe "GET /privacy_policy" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get privacy_policy_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "renders a single top-level heading" do
      travel_to Time.utc(2025, 8, 30) do
        get privacy_policy_path

        expect(response.body.scan(/<h1[\s>]/).size).to eq(1)
      end
    end

    it "titles the page before the site name" do
      travel_to Time.utc(2025, 8, 30) do
        get privacy_policy_path

        expect(response.body).to include(
          "<title>Privacy Policy • Caelus</title>"
        )
      end
    end

    it "describes the page for search engines" do
      travel_to Time.utc(2025, 8, 30) do
        get privacy_policy_path

        expect(response.body).to include(
          ERB::Util.html_escape(I18n.t("privacy_policy.show.meta_description"))
        )
      end
    end
  end
end
