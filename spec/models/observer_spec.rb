# frozen_string_literal: true

require "rails_helper"

RSpec.describe Observer do
  describe ".new" do
    it "raises an error when astronoby_observer is invalid" do
      expect {
        Observer.new(
          astronoby_observer: "invalid",
          time_zone: Time.zone
        )
      }.to raise_error(
        ArgumentError,
        "astronoby_observer must be a Astronoby::Observer"
      )
    end

    it "raises an error when time_zone is invalid" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(0),
        longitude: Astronoby::Angle.from_degrees(0)
      )

      expect {
        Observer.new(
          astronoby_observer: astronoby_observer,
          time_zone: "invalid"
        )
      }.to raise_error(
        ArgumentError,
        "time_zone must be a ActiveSupport::TimeZone"
      )
    end
  end

  describe "delegated methods" do
    it "answers to #latitude" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(10),
        longitude: Astronoby::Angle.from_degrees(20)
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: Time.zone
      )

      expect(observer.latitude.degrees).to eq(10)
    end

    it "answers to #longitude" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(10),
        longitude: Astronoby::Angle.from_degrees(20)
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: Time.zone
      )

      expect(observer.longitude.degrees).to eq(20)
    end

    it "answers to #utc_offset" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(10),
        longitude: Astronoby::Angle.from_degrees(20),
        utc_offset: "-05:00"
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: Time.zone
      )

      expect(observer.utc_offset).to eq("-05:00")
    end
  end
end
