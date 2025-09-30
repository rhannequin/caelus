# frozen_string_literal: true

require "rails_helper"

RSpec.describe NumberHelper do
  include NumberHelper

  describe "#format_number" do
    it "formats a number with default precision and no unit" do
      expect(format_number(123.456)).to eq("123")
    end

    it "formats a number with specified precision" do
      expect(format_number(123.456, precision: 2)).to eq("123.46")
    end

    it "formats a number with trailing zeros if necessary" do
      expect(format_number(123.4, precision: 2)).to eq("123.40")
    end

    it "formats a number with a supported unit" do
      expect(format_number(123.456, unit: :au)).to eq("123 AU")
      expect(format_number(123.456, unit: :degree, precision: 2))
        .to eq("123.46°")
    end

    it "formats a number with a unsupported unit" do
      expect(format_number(123.456, unit: :kg)).to eq("123")
    end

    it "handles zero correctly" do
      expect(format_number(0)).to eq("0")
      expect(format_number(0, precision: 3)).to eq("0.000")
      expect(format_number(0, unit: :au)).to eq("0 AU")
      expect(format_number(0, unit: :au, precision: 2)).to eq("0.00 AU")
    end
  end
end
