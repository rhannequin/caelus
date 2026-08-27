# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessierCatalog do
  describe ".all" do
    it "returns a list of MessierObject" do
      messier_objects = MessierCatalog.all

      expect(messier_objects.size).to eq(110)
      expect(messier_objects).to be_an(Array)
      messier_objects.each do |messier_object|
        expect(messier_object).to be_a(MessierObject)
      end
    end
  end

  describe ".notability" do
    it "tiers the famous objects above the obscure ones" do
      expect(MessierCatalog.notability(31)).to eq(:showpiece)
      expect(MessierCatalog.notability(33)).to eq(:notable)
      expect(MessierCatalog.notability(30)).to eq(:ordinary)
      expect(MessierCatalog.notability(40)).to eq(:faint)
    end

    it "gives every catalogued object a tier" do
      expect(MessierCatalog.all.map(&:notability)).to all(be_present)
    end
  end

  describe ".find_by_number" do
    it "returns the correct MessierObject for a given number" do
      messier_object = MessierCatalog.find_by_number(31)

      expect(messier_object).to be_a(MessierObject)
      expect(messier_object.number).to eq(31)
      expect(messier_object.name).to eq("Andromeda Galaxy")
    end

    it "returns nil for a non-existent Messier number" do
      messier_object = MessierCatalog.find_by_number(999)

      expect(messier_object).to be_nil
    end
  end
end
