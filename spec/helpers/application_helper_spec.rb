# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#document_title" do
    it "falls back to the site name" do
      expect(helper.document_title).to eq("Caelus")
    end

    it "puts the page first and the site name last" do
      helper.content_for(:title, "Moon phase tonight")

      expect(helper.document_title).to eq("Moon phase tonight • Caelus")
    end

    it "escapes the page title only once" do
      helper.content_for(:title, "Tonight's sky")

      expect(helper.document_title).to eq("Tonight&#39;s sky • Caelus")
    end
  end

  describe "#site_heading" do
    it "falls back to the site name" do
      expect(helper.site_heading).to eq("Caelus")
    end

    it "puts the site name before the page name" do
      helper.content_for(:heading, "Moon")

      expect(helper.site_heading).to eq("Caelus • Moon")
    end
  end
end
