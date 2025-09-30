# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubSolarObserver do
  describe "#observer" do
    it "returns the correct observer for a given date" do
      time = Time.utc(2025, 6, 21, 2, 42, 16)
      sun = Sun.new(time: time, observer: double)

      sub_solar_observer = described_class.new(
        sun.apparent.equatorial.right_ascension,
        sun.apparent.equatorial.declination,
        time
      ).observer

      expect(sub_solar_observer.latitude.degrees).to be_within(0.01).of(23.44)
      expect(sub_solar_observer.longitude.degrees).to be_within(0.01).of(139.87)
    end
  end
end
