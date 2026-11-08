# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConjunctionSkyComponent, type: :component do
  it "draws two markers for a planetary conjunction" do
    conjunction = conjunction_for(
      kind: CelestialEvent::PLANETARY_CONJUNCTION,
      primary_body: "Mars",
      secondary_body: "Jupiter",
      peak: Time.utc(2026, 11, 16, 2, 4)
    )

    component = render_inline(described_class.new(conjunction: conjunction))

    expect(component.css("circle.conjunction-sky-body").size).to eq(2)
    expect(component.to_html).to include("1.19° apart")
  end

  it "sizes the brighter planet larger" do
    conjunction = conjunction_for(
      kind: CelestialEvent::PLANETARY_CONJUNCTION,
      primary_body: "Mars",
      secondary_body: "Jupiter",
      peak: Time.utc(2026, 11, 16, 2, 4)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    mars, jupiter = component
      .css("circle.conjunction-sky-body")
      .map { |circle| circle["r"].to_f }

    expect(jupiter).to be > mars
  end

  it "draws the Moon as a phased disc rather than a marker" do
    conjunction = conjunction_for(
      kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
      primary_body: "Saturn",
      peak: Time.utc(2026, 9, 27, 6, 36)
    )

    component = render_inline(described_class.new(conjunction: conjunction))

    expect(component.css("circle.conjunction-sky-body").size).to eq(1)
    expect(component.css("svg svg").size).to eq(1)
  end

  it "separates the pair along the position angle" do
    conjunction = conjunction_for(
      kind: CelestialEvent::PLANETARY_CONJUNCTION,
      primary_body: "Mars",
      secondary_body: "Jupiter",
      peak: Time.utc(2026, 11, 16, 2, 4)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    link = component.css("line.conjunction-sky-link").first
    drawn_gap = Math.hypot(
      link["x2"].to_f - link["x1"].to_f,
      link["y2"].to_f - link["y1"].to_f
    )

    expect(drawn_gap).to be > 0
    expect(component.css("g.conjunction-sky-scale line").size).to eq(3)
  end

  it "names both bodies on the chart" do
    conjunction = conjunction_for(
      kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
      primary_body: "Saturn",
      peak: Time.utc(2026, 9, 27, 6, 36)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    labels = component
      .css("text.conjunction-sky-label")
      .map { |t| t.text.strip }

    expect(labels).to contain_exactly("Moon", "Saturn")
  end

  it "colours each body rather than its role in the pair" do
    conjunction = conjunction_for(
      kind: CelestialEvent::PLANETARY_CONJUNCTION,
      primary_body: "Mars",
      secondary_body: "Jupiter",
      peak: Time.utc(2026, 11, 16, 2, 4)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    fills = component
      .css("circle.conjunction-sky-body")
      .map { |c| c["fill"] }

    expect(fills).to eq([Mars.color, Jupiter.color])
  end

  it "orients the chart to the horizon when the pair is observable" do
    conjunction = conjunction_for(
      kind: CelestialEvent::PLANETARY_CONJUNCTION,
      primary_body: "Mars",
      secondary_body: "Jupiter",
      peak: Time.utc(2026, 11, 16, 2, 4)
    )

    component = render_inline(described_class.new(conjunction: conjunction))

    expect(conjunction.visible?).to be true
    expect(component.to_html).to include("above the")
  end

  it "tilts celestial north by the parallactic angle" do
    conjunction = conjunction_for(
      kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
      primary_body: "Jupiter",
      peak: Time.utc(2026, 10, 6, 10, 23)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    rotation = component
      .css("g.conjunction-sky-compass g")
      .first["transform"][/rotate\(\s*(-?[\d.]+)/, 1]
      .to_f

    expect(conjunction.parallactic_angle.degrees.abs).to be > 5
    expect(rotation)
      .to be_within(0.01).of(conjunction.parallactic_angle.degrees)
  end

  it "falls back to the celestial frame when there is nothing to observe" do
    conjunction = conjunction_for(
      kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
      primary_body: "Venus",
      peak: Time.utc(2026, 10, 12, 4, 37)
    )

    component = render_inline(described_class.new(conjunction: conjunction))

    expect(conjunction.visible?).to be false
    expect(
      component.css("g.conjunction-sky-compass text").map(&:text).map(&:strip)
    ).to eq(%w[N E])
  end

  it "draws the Moon far larger than a planet it meets" do
    conjunction = conjunction_for(
      kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
      primary_body: "Saturn",
      peak: Time.utc(2026, 9, 27, 6, 36)
    )

    component = render_inline(described_class.new(conjunction: conjunction))
    moon = component.css("svg svg circle").first["r"].to_f
    saturn = component.css("circle.conjunction-sky-body").first["r"].to_f

    expect(moon).to be > saturn * 2
  end

  def paris
    Observer.new(
      astronoby_observer: Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.85),
        longitude: Astronoby::Angle.from_degrees(2.35),
        utc_offset: "+01:00"
      ),
      time_zone: Time.find_zone("Europe/Paris")
    )
  end

  def conjunction_for(attributes)
    Conjunction.new(
      celestial_event: create(:celestial_event, **attributes),
      observer: paris
    )
  end
end
