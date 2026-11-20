# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkyCatalogs do
  describe ".main_constellation_lines" do
    it "keeps the bold and normal lines and drops the thin ones" do
      weights = described_class.main_constellation_lines.map(&:weight).uniq

      expect(weights).to contain_exactly(:bold, :normal)
    end

    it "is a subset of all the constellation lines" do
      expect(described_class.constellation_lines.map(&:weight)).to include(:thin)
      expect(described_class.main_constellation_lines.size)
        .to be < described_class.constellation_lines.size
    end
  end
end
