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

    it "names both bodies of a two-body event" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter"
      )

      expect(celestial_event_title(event)).to eq("Mars meets Jupiter")
    end

    it "names the planet the Moon meets" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Venus"
      )

      expect(celestial_event_title(event)).to eq("The Moon meets Venus")
    end
  end

  describe "#celestial_event_kind_name" do
    it "has a name and a title for every kind shown in the timeline" do
      kinds = CelestialEvent::KINDS - CelestialEvent::MOON_PHASE_KINDS

      kinds.each do |kind|
        expect(I18n.exists?("almanac.show.kinds.#{kind}.name"))
          .to be(true), "missing name for #{kind}"
        expect(I18n.exists?("almanac.show.kinds.#{kind}.title"))
          .to be(true), "missing title for #{kind}"
      end
    end

    it "has a name and a glyph for every moon phase shown in the strip" do
      CelestialEvent::MOON_PHASE_KINDS.each do |kind|
        expect(I18n.exists?("moon.phases.#{kind}"))
          .to be(true), "missing name for #{kind}"
        expect(I18n.exists?("moon.phase_emojis.#{kind}"))
          .to be(true), "missing glyph for #{kind}"
      end
    end

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
