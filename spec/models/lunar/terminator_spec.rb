# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lunar::Terminator do
  def terminator(phase_angle:)
    described_class.new(
      phase_angle: Astronoby::Angle.from_degrees(phase_angle),
      bright_limb_angle: Astronoby::Angle.zero
    )
  end

  describe "#axis_ratio" do
    it "is full at new and full moon" do
      expect(terminator(phase_angle: 0).axis_ratio).to be_within(1e-6).of(1)
      expect(terminator(phase_angle: 180).axis_ratio).to be_within(1e-6).of(1)
    end

    it "collapses to zero at the quarter" do
      expect(terminator(phase_angle: 90).axis_ratio).to be_within(1e-6).of(0)
    end

    it "is the cosine of the phase angle in between" do
      expect(terminator(phase_angle: 60).axis_ratio).to be_within(1e-6).of(0.5)
    end
  end
end
