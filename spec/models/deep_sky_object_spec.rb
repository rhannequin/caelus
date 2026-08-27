# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeepSkyObject do
  describe "#designation" do
    it "names a Messier object by its Messier number" do
      deep_sky_object = DeepSkyObject.new(number: 42, catalog: :messier)

      expect(deep_sky_object.designation).to eq("M42")
    end

    it "names an NGC object by its NGC number" do
      deep_sky_object = DeepSkyObject.new(number: 5139, catalog: :ngc)

      expect(deep_sky_object.designation).to eq("NGC 5139")
    end
  end

  describe "#at" do
    it "returns a DeepSkyObjectPosition instance" do
      deep_sky_object = DeepSkyObject.new(number: 1)
      time = Time.utc(2025, 1, 1)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      position = deep_sky_object.at(time, observer: observer)

      expect(position).to be_a(DeepSkyObjectPosition)
      expect(position.deep_sky_object).to eq(deep_sky_object)
      expect(position.time).to eq(time)
      expect(position.observer).to eq(observer)
    end
  end

  describe "#visible_with" do
    it "names the instrument the object is catalogued for" do
      expect(DeepSkyObjectsCatalog.find_by_designation("M45").visible_with)
        .to eq(I18n.t("deep_sky.tool.naked_eye"))
      expect(DeepSkyObjectsCatalog.find_by_designation("M13").visible_with)
        .to eq(I18n.t("deep_sky.tool.binoculars"))
      expect(DeepSkyObjectsCatalog.find_by_designation("M51").visible_with)
        .to eq(I18n.t("deep_sky.tool.small_telescope"))
      expect(DeepSkyObjectsCatalog.find_by_designation("M74").visible_with)
        .to eq(I18n.t("deep_sky.tool.large_telescope"))
    end

    it "does not judge difficulty by magnitude alone" do
      hard_but_bright = DeepSkyObjectsCatalog.find_by_designation("M33")
      easy_but_faint = DeepSkyObjectsCatalog.find_by_designation("M57")

      expect(hard_but_bright.magnitude).to be < easy_but_faint.magnitude
      expect(hard_but_bright.instrument).to eq(:binoculars)
      expect(easy_but_faint.instrument).to eq(:small_telescope)
    end

    it "falls back to a small telescope when the object is not catalogued" do
      expect(DeepSkyObject.new(number: 999).visible_with)
        .to eq(I18n.t("deep_sky.tool.small_telescope"))
    end
  end

  describe "#surface_brightness" do
    it "reveals that a bright galaxy can be harder than a faint nebula" do
      triangulum = DeepSkyObjectsCatalog.find_by_designation("M33")
      ring = DeepSkyObjectsCatalog.find_by_designation("M57")

      expect(triangulum.magnitude).to be < ring.magnitude
      expect(triangulum.surface_brightness).to be > ring.surface_brightness
    end

    it "is nil for objects whose light comes from resolved stars" do
      expect(DeepSkyObjectsCatalog.find_by_designation("M45").surface_brightness)
        .to be_nil
      expect(DeepSkyObjectsCatalog.find_by_designation("M40").surface_brightness)
        .to be_nil
    end

    it "is computed for every diffuse object" do
      diffuse = DeepSkyObjectsCatalog.all.select(&:diffuse?)

      expect(diffuse.size).to be > 40
      expect(diffuse.map(&:surface_brightness)).to all(be_between(15, 26))
    end
  end

  describe "#apparent_area" do
    it "treats a circular object as a disc of its diameter" do
      hercules = DeepSkyObjectsCatalog.find_by_designation("M13")
      radius_arcseconds = 20 * 60 / 2.0

      expect(hercules).to be_circular
      expect(hercules.apparent_area)
        .to be_within(1).of(Math::PI * radius_arcseconds**2)
    end

    it "treats an elongated object as an ellipse of its two axes" do
      sombrero = DeepSkyObjectsCatalog.find_by_designation("M104")

      expect(sombrero).not_to be_circular
      expect(sombrero.major_axis).to be > sombrero.minor_axis
    end
  end
end
