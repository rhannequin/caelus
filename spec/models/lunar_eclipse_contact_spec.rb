# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipseContact do
  describe "#altitude" do
    it "corrects the geocentric place for the observer's parallax" do
      observer = paris
      eclipse = total_eclipse_of_2025_03_14
      instant = eclipse.total.starting_instant

      contact = described_class.new(
        key: :u2,
        instant: instant,
        geometry: eclipse.total.starting_geometry,
        observer: observer
      )

      geocentric = eclipse
        .total
        .starting_geometry
        .moon_coordinates
        .to_horizontal(time: instant.to_time, observer: observer)

      expect(contact.altitude.degrees)
        .to be_within(0.05).of(geocentric.altitude.degrees - 0.9)
    end
  end

  describe "#above_horizon?" do
    it "is true before the Moon sets and false after" do
      eclipse = total_eclipse_of_2025_03_14

      before_moonset = described_class.new(
        key: :u1,
        instant: eclipse.partial.starting_instant,
        geometry: eclipse.partial.starting_geometry,
        observer: paris
      )
      after_moonset = described_class.new(
        key: :u2,
        instant: eclipse.total.starting_instant,
        geometry: eclipse.total.starting_geometry,
        observer: paris
      )

      expect(before_moonset).to be_above_horizon
      expect(after_moonset).not_to be_above_horizon
    end

    it "agrees with what the eclipse reports for that instant" do
      eclipse = total_eclipse_of_2025_03_14
      visibility = eclipse.visibility_from(paris)

      contacts = [
        [
          eclipse.penumbral.starting_instant,
          eclipse.penumbral.starting_geometry
        ],
        [eclipse.partial.starting_instant, eclipse.partial.starting_geometry],
        [eclipse.total.starting_instant, eclipse.total.starting_geometry],
        [eclipse.instant, eclipse.geometry],
        [eclipse.penumbral.ending_instant, eclipse.penumbral.ending_geometry]
      ]

      contacts.each do |instant, geometry|
        contact = described_class.new(
          key: :contact,
          instant: instant,
          geometry: geometry,
          observer: paris
        )

        expect(contact.above_horizon?)
          .to eq(visibility.above_horizon_at?(instant))
      end
    end
  end

  def paris
    Observer.new(
      astronoby_observer: Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.85341),
        longitude: Astronoby::Angle.from_degrees(2.3488),
        utc_offset: "+01:00"
      ),
      time_zone: Time.find_zone("Europe/Paris")
    )
  end

  def total_eclipse_of_2025_03_14
    start_time = Time.utc(2025)

    Astronoby::Moon.eclipse_events(
      ephem: SPK.for_time(start_time),
      start_time: start_time,
      end_time: start_time.end_of_year
    ).first
  end
end
