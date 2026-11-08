# frozen_string_literal: true

require "rails_helper"

RSpec.describe Planetable, type: :model do
  describe ".at" do
    it "positions a body the way a deep-sky object is positioned" do
      time = Time.utc(2026, 10, 6, 12)

      jupiter = Jupiter.at(time, observer: paris)

      expect(jupiter).to be_a(Jupiter)
      expect(jupiter.time).to eq(time)
    end

    it "gives every body the same way to reach its observed position" do
      time = Time.utc(2026, 10, 6, 12)
      bodies = [
        Jupiter,
        Moon,
        Sun,
        DeepSkyObjectsCatalog.find_by_designation("M81")
      ]

      altitudes = bodies.map do |body|
        body.at(time, observer: paris).topocentric.horizontal.altitude
      end

      expect(altitudes).to all(be_a(Astronoby::Angle))
    end
  end

  describe "#rts" do
    it "looks for the events on the observer's local day" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(34.0),
        longitude: Astronoby::Angle.from_degrees(-118.0),
        utc_offset: "-08:00"
      )

      setting_days = [Time.utc(2025, 3, 15, 20), Time.utc(2025, 3, 16, 3)]
        .map { |time| Sun.at(time, observer: observer).rts.setting_time }
        .map { |setting_time| setting_time.getlocal("-08:00").to_date }

      expect(setting_days).to all(eq(Date.new(2025, 3, 15)))
    end
  end

  describe ".astronoby_body" do
    it "exposes the Astronoby class behind the model" do
      expect(Jupiter.astronoby_body).to eq(Astronoby::Jupiter)
      expect(Moon.astronoby_body).to eq(Astronoby::Moon)
    end
  end

  def paris
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.85),
      longitude: Astronoby::Angle.from_degrees(2.35)
    )
  end
end
