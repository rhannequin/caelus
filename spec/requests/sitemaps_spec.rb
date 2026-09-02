# frozen_string_literal: true

require "rails_helper"

RSpec.describe SitemapsController, type: :request do
  describe "GET /sitemap.xml" do
    it "returns a successful response" do
      travel_to Time.utc(2026, 8, 25) do
        get sitemap_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "renders XML" do
      travel_to Time.utc(2026, 8, 25) do
        get sitemap_path

        expect(response.media_type).to eq("application/xml")
      end
    end

    it "lists absolute URLs inside a sitemap urlset" do
      travel_to Time.utc(2026, 8, 25) do
        get sitemap_path

        document = Nokogiri::XML(response.body)
        namespace = "http://www.sitemaps.org/schemas/sitemap/0.9"
        locations = document.css("urlset > url > loc").map(&:text)

        expect(document.root.name).to eq("urlset")
        expect(document.root.namespace.href).to eq(namespace)
        expect(locations).to include("http://www.example.com/moon")
      end
    end

    it "makes every supported lunar eclipse year reachable" do
      travel_to Time.utc(2026, 8, 25) do
        get sitemap_path

        locations = Nokogiri::XML(response.body)
          .css("urlset > url > loc")
          .map(&:text)

        expect(locations).to include(
          "http://www.example.com/lunar_eclipses?year=1900",
          "http://www.example.com/lunar_eclipses?year=2100"
        )
      end
    end

    it "does not report an XML parsing error" do
      travel_to Time.utc(2026, 8, 25) do
        get sitemap_path

        expect(Nokogiri::XML(response.body).errors).to be_empty
      end
    end
  end
end
