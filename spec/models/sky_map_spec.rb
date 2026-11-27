# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkyMap do
  def labels(latitude:, longitude:, time:)
    observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(latitude),
      longitude: Astronoby::Angle.from_degrees(longitude)
    )
    svg = described_class.new(observer: observer, time: time).svg

    Nokogiri::XML(svg).remove_namespaces!.css("text").map { it.text.strip }
  end

  describe "#svg" do
    it "names constellations rather than individual stars" do
      labels = labels(
        latitude: 48.8575,
        longitude: 2.3514,
        time: Time.utc(2026, 11, 8, 20)
      )

      expect(labels).to include("Lyra")
      expect(labels).not_to include("Vega")
    end

    it "labels what the observer can see in the northern sky" do
      labels = labels(
        latitude: 48.8575,
        longitude: 2.3514,
        time: Time.utc(2026, 11, 8, 20)
      )

      expect(labels).to include("N", "E", "S", "W", "Saturn", "Orion")
      expect(labels).not_to include("Crux")
    end

    it "labels what the observer can see in the southern sky" do
      labels = labels(
        latitude: -33.87,
        longitude: 151.2,
        time: Time.utc(2026, 11, 8, 10)
      )

      expect(labels).to include("Crux")
      expect(labels).not_to include("Orion")
    end
  end
end
