# frozen_string_literal: true

require "rails_helper"

RSpec.describe AlmanacController, type: :request do
  describe "GET /almanac" do
    it "returns a successful response" do
      travel_to Time.utc(2025, 8, 30) do
        get almanac_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "lists the events falling within the lookahead window" do
      travel_to Time.utc(2026, 8, 30) do
        create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars",
          peak: Time.utc(2026, 11, 4, 21, 30)
        )
        create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Saturn",
          peak: Time.utc(2028, 3, 1)
        )

        get almanac_path

        expect(response.body).to include("Mars at opposition")
        expect(response.body).to include("November 2026")
        expect(response.body).not_to include("Saturn at opposition")
      end
    end

    it "shows moon phases in the month strip rather than the timeline" do
      travel_to Time.utc(2026, 8, 30) do
        create(
          :celestial_event,
          kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 11, 4, 12)
        )

        get almanac_path

        expect(response.body).to include("almanac-phase-strip")
        expect(response.body).to include("Moon phases in November 2026")
        expect(response.body).not_to include('class="almanac-timeline"')
      end
    end

    it "shows a whole month of phases even mid-month" do
      travel_to Time.utc(2026, 9, 12) do
        early = create(
          :celestial_event,
          kind: CelestialEvent::NEW_MOON,
          peak: Time.utc(2026, 9, 4, 12)
        )
        late = create(
          :celestial_event,
          kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 9, 26, 12)
        )

        get almanac_path

        expect(response.body).to include(early.peak_at.in_time_zone.iso8601)
        expect(response.body).to include(late.peak_at.in_time_zone.iso8601)
      end
    end

    it "drops a month whose events and phases have all passed" do
      travel_to Time.utc(2026, 8, 31, 12) do
        create(
          :celestial_event,
          kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 8, 28, 12)
        )
        create(
          :celestial_event,
          kind: CelestialEvent::NEW_MOON,
          peak: Time.utc(2026, 9, 11, 12)
        )

        get almanac_path

        expect(response.body).not_to include("August 2026")
        expect(response.body).to include("September 2026")
      end
    end

    it "shows lunar apsides in the month header rather than the timeline" do
      travel_to Time.utc(2026, 8, 30) do
        create(
          :celestial_event,
          kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 11, 4, 12)
        )
        create(
          :celestial_event,
          kind: CelestialEvent::MOON_PERIGEE,
          peak: Time.utc(2026, 11, 9, 12)
        )

        get almanac_path

        expect(response.body).to include("almanac-apsis-strip")
        expect(response.body).to include("Moon distance in November 2026")
        expect(response.body).not_to include("The Moon at perigee")
        expect(response.body).not_to include('class="almanac-timeline"')
      end
    end

    it "shows a month whose only upcoming event is a lunar apsis" do
      travel_to Time.utc(2026, 10, 27) do
        create(
          :celestial_event,
          kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 10, 26, 12)
        )
        create(
          :celestial_event,
          kind: CelestialEvent::MOON_APOGEE,
          peak: Time.utc(2026, 10, 30, 12)
        )

        get almanac_path

        expect(response.body).to include("October 2026")
        expect(response.body).to include("almanac-apsis-strip")
      end
    end

    it "counts everything it shows, not only the timeline" do
      travel_to Time.utc(2026, 8, 30) do
        create(:celestial_event, kind: CelestialEvent::FULL_MOON,
          peak: Time.utc(2026, 11, 4, 12))
        create(:celestial_event, kind: CelestialEvent::MOON_APOGEE,
          peak: Time.utc(2026, 11, 9, 12))

        get almanac_path

        expect(response.body).to include("2 events")
      end
    end

    it "shows the last month of the period whole" do
      travel_to Time.utc(2026, 8, 30) do
        create(:celestial_event, kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars", peak: Time.utc(2027, 8, 31, 12))

        get almanac_path

        expect(response.body).to include("Mars at opposition")
      end
    end

    it "renders an empty state when no event is upcoming" do
      travel_to Time.utc(2026, 8, 30) do
        create(:celestial_event, peak: Time.utc(2020, 1, 1))

        get almanac_path

        expect(response.body).to include("No events on the horizon")
      end
    end

    it "tracks the page view" do
      travel_to Time.utc(2026, 8, 30) do
        expect(Appsignal).to(
          receive(:increment_counter)
            .with("page_view", 1, page: "almanac")
        )

        get almanac_path
      end
    end
  end
end
