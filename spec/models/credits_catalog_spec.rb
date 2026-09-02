# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreditsCatalog do
  describe "translations" do
    it "describes every credit" do
      sections = {
        "data" => described_class.data,
        "software" => described_class.software,
        "services" => described_class.services
      }

      untranslated = sections.flat_map do |section, credits|
        credits
          .reject do |credit|
            I18n.exists?(
              "credits.show.sections.#{section}.credits.#{credit.key}"
            )
          end
          .map { |credit| "#{section}/#{credit.key}" }
      end

      expect(untranslated).to be_empty
    end
  end

  describe "licences" do
    it "links every licence it names" do
      unlinked = (described_class.data + described_class.software)
        .select(&:license)
        .reject(&:license_url)
        .map(&:name)

      expect(unlinked).to be_empty
    end
  end
end
