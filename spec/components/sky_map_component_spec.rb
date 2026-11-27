# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkyMapComponent, type: :component do
  it "describes the map for screen readers and embeds its SVG" do
    sky_map = instance_double(SkyMap, svg: '<svg viewBox="0 0 10 10"></svg>')

    result = render_inline(described_class.new(sky_map: sky_map))

    figure = result.css("figure").first
    expect(figure["role"]).to eq("img")
    expect(figure["aria-label"]).to eq(I18n.t("sky.show.description"))
    expect(figure.css("svg").attribute("viewBox").value).to eq("0 0 10 10")
  end
end
