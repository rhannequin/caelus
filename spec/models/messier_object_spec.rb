# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessierObject do
  describe "#messier_number" do
    it "formats the messier number correctly" do
      messier_object = MessierObject.new(number: 42)

      expect(messier_object.messier_number).to eq("M42")
    end
  end

  describe "#at" do
    it "returns a MessierObjectPosition instance" do
      messier_object = MessierObject.new(number: 1)
      time = Time.utc(2025, 1, 1)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      position = messier_object.at(time, observer: observer)

      expect(position).to be_a(MessierObjectPosition)
      expect(position.messier_object).to eq(messier_object)
      expect(position.time).to eq(time)
      expect(position.observer).to eq(observer)
    end
  end

  describe "#visible_with" do
    it "names the instrument the object is catalogued for" do
      expect(MessierCatalog.find_by_number(45).visible_with)
        .to eq(I18n.t("messier.tool.naked_eye"))
      expect(MessierCatalog.find_by_number(13).visible_with)
        .to eq(I18n.t("messier.tool.binoculars"))
      expect(MessierCatalog.find_by_number(51).visible_with)
        .to eq(I18n.t("messier.tool.small_telescope"))
      expect(MessierCatalog.find_by_number(74).visible_with)
        .to eq(I18n.t("messier.tool.large_telescope"))
    end

    it "does not judge difficulty by magnitude alone" do
      hard_but_bright = MessierCatalog.find_by_number(33)
      easy_but_faint = MessierCatalog.find_by_number(57)

      expect(hard_but_bright.magnitude).to be < easy_but_faint.magnitude
      expect(hard_but_bright.instrument).to eq(:binoculars)
      expect(easy_but_faint.instrument).to eq(:small_telescope)
    end

    it "falls back to a small telescope when the object is not catalogued" do
      expect(MessierObject.new(number: 999).visible_with)
        .to eq(I18n.t("messier.tool.small_telescope"))
    end
  end
end
