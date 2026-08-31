# frozen_string_literal: true

require "rails_helper"

RSpec.describe CelestialEventHelper do
  include CelestialEventHelper

  describe "#celestial_event_title" do
    it "names the body and its opposition" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::OPPOSITION,
        primary_body: "Mars"
      )

      expect(celestial_event_title(event)).to eq("Mars at opposition")
    end

    it "names the body and its greatest elongation" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::GREATEST_ELONGATION,
        primary_body: "Mercury"
      )

      expect(celestial_event_title(event))
        .to eq("Mercury at greatest elongation")
    end

    it "names an event that has no body without one" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::LUNAR_ECLIPSE,
        primary_body: nil,
        peak: Time.utc(2026, 8, 28, 12)
      )

      expect(celestial_event_title(event))
        .to eq("Lunar eclipse on August 28, 2026")
    end
  end

  describe "#celestial_event_kind_name" do
    it "returns the human name of the kind" do
      event = build(:celestial_event, kind: CelestialEvent::OPPOSITION)

      expect(celestial_event_kind_name(event)).to eq("Opposition")
    end
  end

  describe "#celestial_event_body_name" do
    it "translates the stored body name" do
      event = build(:celestial_event, primary_body: "Jupiter")

      expect(celestial_event_body_name(event)).to eq("Jupiter")
    end

    it "returns nothing when the event has no body" do
      event = build(:celestial_event, primary_body: nil)

      expect(celestial_event_body_name(event)).to be_nil
    end
  end
end
