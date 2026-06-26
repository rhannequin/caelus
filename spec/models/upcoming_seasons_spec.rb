# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpcomingSeasons, type: :model do
  describe "#each" do
    it "returns the next seasonal events in chronological order" do
      time = Time.utc(2025, 1, 1)

      seasons = described_class.new(time: time).to_a

      expect(seasons.map(&:name)).to eq(
        %i[march_equinox june_solstice september_equinox december_solstice]
      )
      expect(seasons.map(&:time)).to all(be >= time)
      expect(seasons.map(&:time)).to eq(seasons.map(&:time).sort)
    end

    it "limits the number of returned seasons" do
      time = Time.utc(2025, 1, 1)

      seasons = described_class.new(time: time, count: 2).to_a

      expect(seasons.length).to eq(2)
      expect(seasons.map(&:name)).to eq(%i[march_equinox june_solstice])
    end

    context "when seasons of the current year have already passed" do
      it "rolls over into the next year" do
        time = Time.utc(2025, 10, 1)

        seasons = described_class.new(time: time).to_a

        expect(seasons.map(&:name)).to eq(
          %i[december_solstice march_equinox june_solstice september_equinox]
        )
        expect(seasons.first.time.year).to eq(2025)
        expect(seasons.last.time.year).to eq(2026)
      end
    end
  end
end
