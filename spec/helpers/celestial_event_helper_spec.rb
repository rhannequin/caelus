# frozen_string_literal: true

require "rails_helper"

RSpec.describe CelestialEventHelper do
  include CelestialEventHelper

  describe "#celestial_event_title" do
    it "names the body and its opposition" do
      event = build(
        :celestial_event,
        kind: CelestialEvent::OPPOSITION,
        primary_body: "Mars"
      )

      expect(celestial_event_title(event)).to eq("Mars at opposition")
    end

    it "names the body and its maximum elongation" do
      event = build(
        :celestial_event,
        kind: CelestialEvent::MAXIMUM_ELONGATION,
        primary_body: "Mercury"
      )

      expect(celestial_event_title(event))
        .to eq("Mercury at maximum elongation")
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
  end
end
