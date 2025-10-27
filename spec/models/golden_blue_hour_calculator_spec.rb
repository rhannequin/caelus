# frozen_string_literal: true

require "rails_helper"

RSpec.describe GoldenBlueHourCalculator do
  describe "#morning_golden_hour" do
    it "returns an array of two Time instances" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        utc_offset: "+00:00"
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: ActiveSupport::TimeZone["UTC"]
      )
      date = Date.new(2025, 10, 1)
      calculator = GoldenBlueHourCalculator.new(
        observer: observer,
        date: date
      )

      result = calculator.morning_golden_hour

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to be_a(Time)
      expect(result.last).to be_a(Time)
    end
  end

  describe "#evening_golden_hour" do
    it "returns an array of two Time instances" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        utc_offset: "+00:00"
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: ActiveSupport::TimeZone["UTC"]
      )
      date = Date.new(2025, 10, 1)
      calculator = GoldenBlueHourCalculator.new(
        observer: observer,
        date: date
      )

      result = calculator.evening_golden_hour

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to be_a(Time)
      expect(result.last).to be_a(Time)
    end
  end

  describe "#morning_blue_hour" do
    it "returns an array of two Time instances" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        utc_offset: "+00:00"
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: ActiveSupport::TimeZone["UTC"]
      )
      date = Date.new(2025, 10, 1)
      calculator = GoldenBlueHourCalculator.new(
        observer: observer,
        date: date
      )

      result = calculator.morning_blue_hour

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to be_a(Time)
      expect(result.last).to be_a(Time)
    end
  end

  describe "#evening_blue_hour" do
    it "returns an array of two Time instances" do
      astronoby_observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        utc_offset: "+00:00"
      )
      observer = Observer.new(
        astronoby_observer: astronoby_observer,
        time_zone: ActiveSupport::TimeZone["UTC"]
      )
      date = Date.new(2025, 10, 1)
      calculator = GoldenBlueHourCalculator.new(
        observer: observer,
        date: date
      )

      result = calculator.evening_blue_hour

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first).to be_a(Time)
      expect(result.last).to be_a(Time)
    end
  end
end
