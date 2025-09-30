# frozen_string_literal: true

require "rails_helper"

RSpec.describe Moon, type: :model do
  describe "#age" do
    it "returns the age in days since the last new moon" do
      observer = double
      time = Time.utc(2025, 8, 27)

      age = described_class
        .new(observer: observer, time: time)
        .age

      expect(age.round(1)).to eq(3.7)
    end

    context "when it is right before a new moon" do
      it "still refers to the previous new moon" do
        observer = double
        time = Time.utc(2025, 8, 23, 6, 6)

        age = described_class
          .new(observer: observer, time: time)
          .age

        expect(age.round(1)).to eq(29.5)
      end
    end

    context "when it is right after a new moon" do
      it "refers to the new moon that just happened" do
        observer = double
        time = Time.utc(2025, 8, 23, 6, 7)

        age = described_class
          .new(observer: observer, time: time)
          .age

        expect(age.round(1)).to eq(0.0)
      end
    end
  end

  describe "#current_phase_name" do
    context "when we're right before the new moon" do
      it "returns :new_moon" do
        observer = double
        time = Time.utc(2025, 8, 22, 19)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:new_moon)
      end
    end

    context "when we're right after the new moon" do
      it "returns :new_moon" do
        observer = double
        time = Time.utc(2025, 8, 23, 18)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:new_moon)
      end
    end

    context "when we're in the waxing crescent period" do
      it "returns :waxing_crescent" do
        observer = double
        time = Time.utc(2025, 8, 25)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:waxing_crescent)
      end
    end

    context "when we're right before the first quarter" do
      it "returns :first_quarter" do
        observer = double
        time = Time.utc(2025, 8, 30, 19)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:first_quarter)
      end
    end

    context "when we're right after the first quarter" do
      it "returns :first_quarter" do
        observer = double
        time = Time.utc(2025, 8, 31, 18)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:first_quarter)
      end
    end

    context "when we're in the waxing gibbous period" do
      it "returns :waxing_gibbous" do
        observer = double
        time = Time.utc(2025, 9, 2)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:waxing_gibbous)
      end
    end

    context "when we're right before the full moon" do
      it "returns :full_moon" do
        observer = double
        time = Time.utc(2025, 9, 7, 7)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:full_moon)
      end
    end

    context "when we're right after the full moon" do
      it "returns :full_moon" do
        observer = double
        time = Time.utc(2025, 9, 8, 6)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:full_moon)
      end
    end

    context "when we're in to the waning gibbous period" do
      it "returns :waning_gibbous" do
        observer = double
        time = Time.utc(2025, 9, 11)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:waning_gibbous)
      end
    end

    context "when we're right before the last quarter" do
      it "returns :last_quarter" do
        observer = double
        time = Time.utc(2025, 9, 13, 23)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:last_quarter)
      end
    end

    context "when we're right after the last quarter" do
      it "returns :last_quarter" do
        observer = double
        time = Time.utc(2025, 9, 14, 22)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:last_quarter)
      end
    end

    context "when we're in the waning crescent period" do
      it "returns :waning_crescent" do
        observer = double
        time = Time.utc(2025, 9, 16)

        phase_name = described_class
          .new(observer: observer, time: time)
          .current_phase_name

        expect(phase_name).to eq(:waning_crescent)
      end
    end
  end

  describe "#next_phase" do
    it "returns the next phase (Astronoby::MoonPhase)" do
      observer = double
      time = Time.utc(2025, 8, 30)

      next_phase = described_class
        .new(observer: observer, time: time)
        .next_phase

      expect(next_phase.phase).to eq(:first_quarter)
      expect(next_phase.time.to_date).to eq(Date.new(2025, 8, 31))
    end

    context "when the next phase is a minor one" do
      it "still returns the major next phase (Astronoby::MoonPhase)" do
        observer = double
        time = Time.utc(2025, 9, 1)

        next_phase = described_class
          .new(observer: observer, time: time)
          .next_phase

        expect(next_phase.phase).to eq(:full_moon)
        expect(next_phase.time.to_date).to eq(Date.new(2025, 9, 7))
      end
    end
  end

  describe "#velocity" do
    it "returns the geometric geocentric velocity as a Asronoby::Velocity" do
      observer = double
      time = Time.utc(2025, 9, 14)

      velocity = described_class
        .new(observer: observer, time: time)
        .velocity

      expect(velocity).to be_a(Astronoby::Velocity)
      expect(velocity.kilometers_per_second.round(2)).to eq(1.06)
    end
  end
end
