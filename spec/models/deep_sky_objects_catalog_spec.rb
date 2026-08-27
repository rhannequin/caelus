# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeepSkyObjectsCatalog do
  describe ".all" do
    it "covers both catalogues, including the far southern sky" do
      declinations = DeepSkyObjectsCatalog.all.map do |deep_sky_object|
        deep_sky_object.j2000_coordinates.declination.degrees
      end

      expect(DeepSkyObjectsCatalog.all.map(&:catalog).uniq)
        .to contain_exactly(:messier, :ngc)
      expect(declinations.min).to be < -70
      expect(DeepSkyObjectsCatalog.all.map(&:designation).uniq.size)
        .to eq(DeepSkyObjectsCatalog.all.size)
    end

    it "returns a list of DeepSkyObject" do
      deep_sky_objects = DeepSkyObjectsCatalog.all

      expect(deep_sky_objects.size).to eq(128)
      expect(deep_sky_objects).to be_an(Array)
      deep_sky_objects.each do |deep_sky_object|
        expect(deep_sky_object).to be_a(DeepSkyObject)
      end
    end
  end

  describe ".notability" do
    it "tiers the famous objects above the obscure ones" do
      expect(DeepSkyObjectsCatalog.notability("M31")).to eq(:showpiece)
      expect(DeepSkyObjectsCatalog.notability("M33")).to eq(:notable)
      expect(DeepSkyObjectsCatalog.notability("M30")).to eq(:ordinary)
      expect(DeepSkyObjectsCatalog.notability("M40")).to eq(:faint)
      expect(DeepSkyObjectsCatalog.notability("NGC 5139")).to eq(:showpiece)
    end

    it "gives every catalogued object a tier" do
      expect(DeepSkyObjectsCatalog.all.map(&:notability)).to all(be_present)
    end
  end

  describe ".instrument" do
    it "rates difficulty by how the object actually looks, not its magnitude" do
      expect(DeepSkyObjectsCatalog.instrument("M45")).to eq(:naked_eye)
      expect(DeepSkyObjectsCatalog.instrument("M13")).to eq(:binoculars)
      expect(DeepSkyObjectsCatalog.instrument("M51")).to eq(:small_telescope)
      expect(DeepSkyObjectsCatalog.instrument("M74")).to eq(:large_telescope)
      expect(DeepSkyObjectsCatalog.instrument("NGC 3372")).to eq(:naked_eye)
    end

    it "gives every catalogued object an instrument" do
      expect(DeepSkyObjectsCatalog.all.map(&:instrument)).to all(be_present)
    end
  end

  describe ".find_by_designation" do
    it "returns the correct DeepSkyObject for a given number" do
      deep_sky_object = DeepSkyObjectsCatalog.find_by_designation("M31")

      expect(deep_sky_object).to be_a(DeepSkyObject)
      expect(deep_sky_object.number).to eq(31)
      expect(deep_sky_object.name).to eq("Andromeda Galaxy")
    end

    it "returns nil for an unknown designation" do
      deep_sky_object = DeepSkyObjectsCatalog.find_by_designation("M999")

      expect(deep_sky_object).to be_nil
    end
  end
end
