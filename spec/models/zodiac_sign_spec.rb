# frozen_string_literal: true

require "rails_helper"

RSpec.describe ZodiacSign do
  describe ".for_date" do
    it "handles all zodiac signs correctly" do
      test_dates = [
        {date: Date.new(2025, 1, 1), expected: "Capricornus"},
        {date: Date.new(2025, 1, 15), expected: "Capricornus"},
        {date: Date.new(2025, 2, 1), expected: "Aquarius"},
        {date: Date.new(2025, 2, 15), expected: "Aquarius"},
        {date: Date.new(2025, 3, 1), expected: "Pisces"},
        {date: Date.new(2025, 3, 15), expected: "Pisces"},
        {date: Date.new(2025, 4, 1), expected: "Aries"},
        {date: Date.new(2025, 4, 15), expected: "Aries"},
        {date: Date.new(2025, 5, 1), expected: "Taurus"},
        {date: Date.new(2025, 5, 15), expected: "Taurus"},
        {date: Date.new(2025, 6, 1), expected: "Gemini"},
        {date: Date.new(2025, 6, 15), expected: "Gemini"},
        {date: Date.new(2025, 7, 1), expected: "Cancer"},
        {date: Date.new(2025, 7, 15), expected: "Cancer"},
        {date: Date.new(2025, 8, 1), expected: "Leo"},
        {date: Date.new(2025, 8, 15), expected: "Leo"},
        {date: Date.new(2025, 9, 1), expected: "Virgo"},
        {date: Date.new(2025, 9, 15), expected: "Virgo"},
        {date: Date.new(2025, 10, 1), expected: "Libra"},
        {date: Date.new(2025, 10, 15), expected: "Libra"},
        {date: Date.new(2025, 11, 1), expected: "Scorpius"},
        {date: Date.new(2025, 11, 15), expected: "Scorpius"},
        {date: Date.new(2025, 12, 1), expected: "Sagittarius"},
        {date: Date.new(2025, 12, 15), expected: "Sagittarius"}
      ]

      test_dates.each do |test_case|
        sign = described_class.for_date(test_case[:date])
        expect(sign.constellation.name).to eq(test_case[:expected])
      end
    end

    it "returns the correct zodiac sign for boundary dates" do
      expect(
        described_class.for_date(Date.new(2025, 1, 19)).constellation.name
      ).to eq("Capricornus")
      expect(
        described_class.for_date(Date.new(2025, 1, 20)).constellation.name
      ).to eq("Aquarius")
      expect(
        described_class.for_date(Date.new(2025, 12, 21)).constellation.name
      ).to eq("Sagittarius")
      expect(
        described_class.for_date(Date.new(2025, 12, 22)).constellation.name
      ).to eq("Capricornus")
    end
  end
end
