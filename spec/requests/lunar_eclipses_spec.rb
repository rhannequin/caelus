# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipsesController, type: :request do
  describe "GET /lunar_eclipses" do
    it "says whether each eclipse is visible from the observer" do
      travel_to Time.utc(2027, 1, 1) do
        get lunar_eclipses_path(year: 2027)

        expect(response.body).to include("Visible")
        expect(response.body).to include("Not visible")
      end
    end

    it "returns a successful response" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path

        expect(response).to have_http_status(:ok)
      end
    end

    it "tracks the page view" do
      travel_to Time.utc(2026, 8, 25) do
        expect(Appsignal).to(
          receive(:increment_counter)
            .with("page_view", 1, page: "lunar_eclipses")
        )

        get lunar_eclipses_path
      end
    end

    it "canonicalises the current year to the bare path" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: 2026)

        expect(response.body).to include(
          '<link rel="canonical" ' \
            'href="http://www.example.com/lunar_eclipses">'
        )
      end
    end

    it "canonicalises another year to its own parameter" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: 2027)

        expect(response.body).to include(
          '<link rel="canonical" ' \
            'href="http://www.example.com/lunar_eclipses?year=2027">'
        )
      end
    end

    it "canonicalises an out-of-range year to the year it clamps to" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: 99999)

        expect(response.body).to include(
          '<link rel="canonical" ' \
            'href="http://www.example.com/lunar_eclipses?year=2100">'
        )
      end
    end

    it "canonicalises a malformed year to the bare path" do
      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: "abc")

        expect(response.body).to include(
          '<link rel="canonical" ' \
            'href="http://www.example.com/lunar_eclipses">'
        )
      end
    end

    context "without year parameter" do
      it "returns lunar eclipses for the current year" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path

          expect(response.body).to include("Lunar Eclipses in 2026")
        end
      end
    end

    context "with a malformed year parameter" do
      it "falls back to the current year" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path(year: "abc")

          expect(response.body).to include("Lunar Eclipses in 2026")
        end
      end

      it "does not accept a year with trailing characters" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path(year: "1900nonsense")

          expect(response.body).to include("Lunar Eclipses in 2026")
        end
      end
    end

    context "with year parameter" do
      it "returns lunar eclipses for the specified year" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path(year: 2027)

          expect(response).to have_http_status(:ok)
        end
      end

      it "returns lunar eclipses for a year far from the current one" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path(year: 1999)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Lunar Eclipses in 1999")
        end
      end

      it "clamps a year outside the supported range" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path(year: 3000)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Lunar Eclipses in 2100")
        end
      end
    end
  end

  describe "GET /lunar_eclipses/:id" do
    it "describes what the observer sees of the eclipse" do
      travel_to Time.utc(2025, 1, 1) do
        get lunar_eclipse_path(id: "2025-03-14")

        expect(response.body).to include("Visibility")
        expect(response.body)
          .to include("The Moon sets while the eclipse is still under way.")
        expect(response.body).to include("Moon sets")
      end
    end

    it "shows where to look for the Moon at each contact" do
      travel_to Time.utc(2025, 1, 1) do
        get lunar_eclipse_path(id: "2025-03-14")

        expect(response.body).to include("20.8° alt · 249° az")
        expect(response.body).to include("-3.1° alt · 277° az")
      end
    end

    it "reports each phase separately" do
      travel_to Time.utc(2025, 1, 1) do
        get lunar_eclipse_path(id: "2025-03-14")

        # Paris loses the Moon before totality begins.
        expect(response.body).to include("Totality")
        expect(response.body).to include("Not visible")
      end
    end

    context "with a valid date" do
      it "returns a successful response" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipse_path(id: "2026-08-28")

          expect(response).to have_http_status(:ok)
        end
      end

      it "tracks the page view" do
        travel_to Time.utc(2026, 8, 25) do
          expect(Appsignal).to(
            receive(:increment_counter)
              .with("page_view", 1, page: "lunar_eclipse")
          )

          get lunar_eclipse_path(id: "2026-08-28")
        end
      end
    end

    context "with a date in another year" do
      it "returns a successful response" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipse_path(id: "1999-07-28")

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "with an invalid date" do
      it "returns a 404 response" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipse_path(id: "2026-08-29")

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "with a date outside the supported range" do
      it "returns a 404 response" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipse_path(id: "1850-01-01")

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "caching" do
    it "computes a year of eclipses once for the list and the details" do
      allow(Rails).to receive(:cache).and_return(
        ActiveSupport::Cache::MemoryStore.new
      )
      allow(Astronoby::Moon).to receive(:eclipse_events).and_call_original

      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: 2026)
        get lunar_eclipses_path(year: 2026)
        get lunar_eclipse_path(id: "2026-03-03")

        expect(Astronoby::Moon).to have_received(:eclipse_events).once
      end
    end

    it "computes each year separately" do
      allow(Rails).to receive(:cache).and_return(
        ActiveSupport::Cache::MemoryStore.new
      )
      allow(Astronoby::Moon).to receive(:eclipse_events).and_call_original

      travel_to Time.utc(2026, 8, 25) do
        get lunar_eclipses_path(year: 2026)
        get lunar_eclipses_path(year: 2027)

        expect(Astronoby::Moon).to have_received(:eclipse_events).twice
      end
    end
  end
end
