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
    it "returns the correct visibility method based on magnitude" do
      naked_eye_object = MessierObject.new(magnitude: 3.5)
      binoculars_object = MessierObject.new(magnitude: 5.0)
      telescope_object = MessierObject.new(magnitude: 7.0)

      expect(naked_eye_object.visible_with)
        .to eq(I18n.t("messier.tool.naked_eye"))
      expect(binoculars_object.visible_with)
        .to eq(I18n.t("messier.tool.binoculars"))
      expect(telescope_object.visible_with)
        .to eq(I18n.t("messier.tool.telescope"))
    end
  end
end
