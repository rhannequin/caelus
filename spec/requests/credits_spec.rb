# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreditsController, type: :request do
  describe "GET /credits" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "renders a single top-level heading" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        expect(response.body.scan(/<h1[\s>]/).size).to eq(1)
      end
    end

    it "titles the page before the site name" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        expect(response.body).to include("<title>Credits • Caelus</title>")
      end
    end

    it "describes the page for search engines" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        expect(response.body).to include(
          ERB::Util.html_escape(I18n.t("credits.show.meta_description"))
        )
      end
    end

    it "credits the ephemeris the positions are computed from" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        expect(response.body).to include(
          "https://www.imcce.fr/recherche/equipes/asd/inpop/download19a"
        )
        expect(response.body).to include("INPOP19a")
      end
    end

    it "names the licence of every credit that has one" do
      travel_to Time.utc(2025, 8, 30) do
        get credits_path

        licences = (CreditsCatalog.data + CreditsCatalog.software)
          .filter_map(&:license)
          .uniq

        licences.each do |licence|
          expect(response.body).to include(licence)
        end
      end
    end
  end
end
