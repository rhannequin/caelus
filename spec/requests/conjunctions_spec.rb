# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConjunctionsController, type: :request do
  describe "GET /conjunctions/:id" do
    it "addresses a conjunction by its date and bodies" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      get "/conjunctions/2026-09-27-moon-saturn"

      expect(response).to have_http_status(:ok)
      expect(conjunction_path(event))
        .to eq("/conjunctions/2026-09-27-moon-saturn")
    end

    it "shows both bodies of a planetary conjunction" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      get conjunction_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mars meets Jupiter")
      expect(response.body).to include("In the sky")
    end

    it "names the Moon as the first body of a lunar conjunction" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      get conjunction_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("The Moon meets Saturn")
    end

    it "lists every night the pair is observable, not just the peak" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      get conjunction_path(event)

      expect(response.body).to include("Best time")
      expect(response.body).to include("nights around the peak")
    end

    it "withholds the observing details when the pair never clears the horizon" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Venus",
        peak: Time.utc(2026, 10, 12, 4, 37)
      )

      get conjunction_path(event)

      expect(response.body).not_to include("Best time")
      expect(response.body).to include("shares the daytime sky")
    end

    it "blames the Sun only when the pair is actually near it" do
      near = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Venus",
        peak: Time.utc(2026, 10, 12, 4, 37)
      )
      far = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Jupiter",
        peak: Time.utc(2027, 6, 9, 9, 35, 20)
      )

      get conjunction_path(near)
      expect(response.body).to include("shares the daytime sky")

      get conjunction_path(far)
      expect(response.body).not_to include("shares the daytime sky")
    end

    it "does not serve a celestial event that is not a conjunction" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::LUNAR_ECLIPSE,
        peak: Time.utc(2026, 8, 28, 12)
      )

      get conjunction_path(event)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found response for a body it cannot resolve" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Pluto",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      get conjunction_path(event)

      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found response when no event matches the slug" do
      get conjunction_path(id: "2026-11-16-mars-jupiter")

      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found response for a slug that is not a date" do
      get conjunction_path(id: "mars-jupiter")

      expect(response).to have_http_status(:not_found)
    end

    it "does not serve a conjunction under another day's slug" do
      create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      get conjunction_path(id: "2026-11-17-mars-jupiter")

      expect(response).to have_http_status(:not_found)
    end

    it "tracks the page view" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      expect(Appsignal).to(
        receive(:increment_counter).with("page_view", 1, page: "conjunction")
      )

      get conjunction_path(event)
    end
  end
end
