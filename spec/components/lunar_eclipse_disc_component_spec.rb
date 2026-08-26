# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipseDiscComponent, type: :component do
  def phase(from: 0, to: 2)
    Astronoby::EclipsePhase.new(
      starting_instant: Astronoby::Instant.from_time(
        Time.utc(2026, 3, 3, 10) + from.hours
      ),
      ending_instant: Astronoby::Instant.from_time(
        Time.utc(2026, 3, 3, 10) + to.hours
      )
    )
  end

  def build_eclipse(
    kind: :total,
    umbral_magnitude: 1.151,
    penumbral_magnitude: 2.184,
    gamma: -0.376,
    axis_distance_km: 2401,
    partial: phase,
    total: phase(from: 0.5, to: 1.5)
  )
    instance_double(
      Astronoby::LunarEclipse,
      kind: kind,
      umbral_magnitude: umbral_magnitude,
      penumbral_magnitude: penumbral_magnitude,
      gamma: gamma,
      shadow_axis_distance: Astronoby::Distance.from_kilometers(
        axis_distance_km
      ),
      penumbral: phase,
      partial: partial,
      total: total,
      penumbral?: kind == :penumbral
    )
  end

  def build_penumbral_eclipse
    build_eclipse(
      kind: :penumbral,
      umbral_magnitude: -0.132,
      penumbral_magnitude: 0.956,
      gamma: 1.061,
      axis_distance_km: 6767,
      partial: nil,
      total: nil
    )
  end

  def build_partial_eclipse
    build_eclipse(
      kind: :partial,
      umbral_magnitude: 0.93,
      penumbral_magnitude: 1.965,
      gamma: 0.496,
      axis_distance_km: 3166,
      total: nil
    )
  end

  def render_disc(lunar_eclipse, **options)
    render_inline(
      described_class.new(lunar_eclipse: lunar_eclipse, **options)
    ).to_html
  end

  def moon_cy(html)
    html[/<circle cx="0" cy="(-?[\d.]+)" r="1" fill="#d4d0c3"/, 1].to_f
  end

  def moon_offset(html)
    moon_cy(html).abs
  end

  def contact_marks(html)
    html.scan(
      /<circle cx="-?[\d.]+" cy="-?[\d.]+" r="1" fill="none" stroke="#9c9188"/
    ).size
  end

  def view_box(html)
    html[/viewBox="([^"]+)"/, 1].split.map(&:to_f)
  end

  def umbra_radius(html)
    html
      .scan(/<circle\s+cx="0"\s+cy="0"\s+r="([\d.]+)"/m)
      .flatten
      .map(&:to_f)
      .min
  end

  describe "the depth the figure draws the Moon at" do
    it "puts the whole Moon inside the umbra for a total eclipse" do
      html = render_disc(build_eclipse, detailed: true)

      expect(umbra_radius(html)).to be >= moon_offset(html) + 1
    end

    it "straddles the umbra edge for a partial eclipse" do
      html = render_disc(build_partial_eclipse, detailed: true)

      expect(umbra_radius(html)).to be_between(
        moon_offset(html) - 1,
        moon_offset(html) + 1
      ).exclusive
    end

    it "keeps the Moon clear of the umbra for a penumbral eclipse" do
      html = render_disc(build_penumbral_eclipse, detailed: true)

      expect(umbra_radius(html)).to be <= moon_offset(html) - 1
    end

    it "places the Moon at its distance from the shadow axis" do
      html = render_disc(build_eclipse(axis_distance_km: 2401), detailed: true)

      expect(moon_offset(html)).to be_within(0.001).of(
        2401 / LunarEclipseDiscComponent::MOON_RADIUS_KM
      )
    end
  end

  describe "which side of the axis the Moon passes" do
    it "draws a Moon north of the axis above it" do
      html = render_disc(build_eclipse(gamma: 0.348), detailed: true)

      expect(moon_cy(html)).to be_negative
    end

    it "draws a Moon south of the axis below it" do
      html = render_disc(build_eclipse(gamma: -0.348), detailed: true)

      expect(moon_cy(html)).to be_positive
    end
  end

  describe "the detailed figure" do
    it "marks every contact on the Moon's path" do
      html = render_disc(build_eclipse, detailed: true)

      expect(html.scan("<line ").size).to eq(1)
      expect(contact_marks(html)).to eq(6)
    end

    it "marks only the penumbral contacts when there is no umbral phase" do
      html = render_disc(build_penumbral_eclipse, detailed: true)

      expect(contact_marks(html)).to eq(2)
    end

    it "marks the umbral but not the totality contacts for a partial" do
      html = render_disc(build_partial_eclipse, detailed: true)

      expect(contact_marks(html)).to eq(4)
    end
  end

  describe "the compact figure" do
    it "frames the Moon in a square viewBox" do
      html = render_disc(build_eclipse)
      _x, y, width, height = view_box(html)

      expect(width).to eq(height)
      expect(y + height / 2).to be_within(0.001).of(moon_cy(html))
    end

    it "renders as tall as it is wide" do
      html = render_disc(build_eclipse, size: 96)

      expect(html).to include('width="96"').and include('height="96"')
    end

    it "draws no path or contacts" do
      html = render_disc(build_eclipse)

      expect(html).not_to include("<line")
    end
  end

  describe "the accessible description" do
    it "names the kind, the offset and both immersions" do
      html = render_disc(build_eclipse, detailed: true)

      expect(html).to include("Total Lunar Eclipse")
      expect(html).to include("1.38 Moon radii south")
      expect(html).to include("115% of its diameter inside the umbra")
      expect(html).to include("218% inside the penumbra")
    end

    it "reports no umbral immersion for a penumbral eclipse" do
      html = render_disc(build_penumbral_eclipse, detailed: true)

      expect(html).to include("none of its diameter inside the umbra")
    end

    it "labels the figure for screen readers" do
      html = render_disc(build_eclipse)

      expect(html).to include("The Moon in Earth's shadow")
      expect(html).to match(/aria-labelledby="eclipse-disc-title-\h+ /)
    end
  end
end
