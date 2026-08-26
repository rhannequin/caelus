# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipsesController, type: :request do
  describe "GET /lunar_eclipses" do
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

    context "without year parameter" do
      it "returns lunar eclipses for the current year" do
        travel_to Time.utc(2026, 8, 25) do
          get lunar_eclipses_path

          expect(response).to have_http_status(:ok)
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
end
