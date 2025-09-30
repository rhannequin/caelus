# frozen_string_literal: true

require "rails_helper"

RSpec.describe DateTimeHelper do
  include DateTimeHelper

  describe "#nillable_datetime" do
    context "when datetime is nil" do
      it "returns the empty set symbol" do
        expect(nillable_datetime(nil)).to eq("∅")
      end
    end

    context "when datetime is present" do
      it "formats the datetime using the default format" do
        datetime = Time.zone.parse("2024-06-15 14:30:00")

        expect(nillable_datetime(datetime))
          .to eq("Sat, 15 Jun 2024 14:30:00 +0000")
      end

      it "formats the datetime using a custom format" do
        datetime = Time.zone.parse("2024-06-15 14:30:00")

        expect(nillable_datetime(datetime, format: :short))
          .to eq("15 Jun 14:30")
      end
    end
  end

  describe "#duration_to_human" do
    it "handles floating point durations" do
      expect(duration_to_human(125.7)).to eq("2m 5s")
    end

    context "when the duration is over an hour" do
      it "returns the duration in hours and minutes" do
        expect(duration_to_human(3665)).to eq("1h 1m")
      end
    end

    context "when the duration is under an hour" do
      it "returns the duration in minutes and seconds" do
        expect(duration_to_human(125)).to eq("2m 5s")
      end
    end

    context "when the duration is negative" do
      it "returns the duration with a negative sign" do
        expect(duration_to_human(-3665)).to eq("-1h 1m")
      end
    end
  end
end
