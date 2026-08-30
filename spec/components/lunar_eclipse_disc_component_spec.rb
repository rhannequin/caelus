# frozen_string_literal: true

require "rails_helper"

RSpec.describe LunarEclipseDiscComponent, type: :component do
  def moon_radius_km
    LunarEclipseDiscComponent::MOON_RADIUS_KM
  end

  def build_geometry(
    axis_distance_km:,
    position_angle:,
    umbra_km: 4664,
    penumbra_km: 8254,
    north_of_axis: true
  )
    Astronoby::LunarEclipseGeometry.new(
      axis_distance: Astronoby::Distance.from_kilometers(axis_distance_km),
      position_angle: Astronoby::Angle.from_degrees(position_angle),
      umbra_radius: Astronoby::Distance.from_kilometers(umbra_km),
      penumbra_radius: Astronoby::Distance.from_kilometers(penumbra_km),
      moon_distance: Astronoby::Distance.from_kilometers(400_000),
      moon_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hours(11.64),
        declination: Astronoby::Angle.from_degrees(2.68)
      ),
      north_of_axis: north_of_axis
    )
  end

  def build_phase(starting_geometry:, ending_geometry:, from: 0, to: 2)
    Astronoby::LunarEclipsePhase.new(
      starting_instant: Astronoby::Instant.from_time(
        Time.utc(2026, 3, 3, 10) + from.hours
      ),
      ending_instant: Astronoby::Instant.from_time(
        Time.utc(2026, 3, 3, 10) + to.hours
      ),
      starting_geometry: starting_geometry,
      ending_geometry: ending_geometry
    )
  end

  def build_penumbral_phase(
    starting_geometry: build_geometry(
      axis_distance_km: 9989,
      position_angle: 104.30
    ),
    ending_geometry: build_geometry(
      axis_distance_km: 9994,
      position_angle: 312.13
    )
  )
    build_phase(
      starting_geometry: starting_geometry,
      ending_geometry: ending_geometry
    )
  end

  def build_partial_phase
    build_phase(
      starting_geometry: build_geometry(
        axis_distance_km: 6403,
        position_angle: 96.19
      ),
      ending_geometry: build_geometry(
        axis_distance_km: 6402,
        position_angle: 320.26
      )
    )
  end

  def build_total_phase(
    starting_geometry: build_geometry(
      axis_distance_km: 2926,
      position_angle: 243.07
    )
  )
    build_phase(
      starting_geometry: starting_geometry,
      ending_geometry: build_geometry(
        axis_distance_km: 2925,
        position_angle: 173.39
      )
    )
  end

  def build_eclipse(
    kind: :total,
    umbral_magnitude: 1.151,
    penumbral_magnitude: 2.184,
    gamma: -0.376,
    geometry: build_geometry(axis_distance_km: 2401, position_angle: 208.22),
    penumbral: build_penumbral_phase,
    partial: build_partial_phase,
    total: build_total_phase
  )
    instance_double(
      Astronoby::LunarEclipse,
      kind: kind,
      umbral_magnitude: umbral_magnitude,
      penumbral_magnitude: penumbral_magnitude,
      gamma: gamma,
      geometry: geometry,
      penumbral: penumbral,
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
      geometry: build_geometry(axis_distance_km: 6767, position_angle: 8.4),
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
      geometry: build_geometry(axis_distance_km: 3166, position_angle: 21.5),
      total: nil
    )
  end

  def render_disc(lunar_eclipse, **options)
    render_inline(
      described_class.new(lunar_eclipse: lunar_eclipse, **options)
    ).to_html
  end

  def moon_centre(html)
    match = html.match(
      /<circle cx="(-?[\d.]+)"\s+cy="(-?[\d.]+)"\s+r="1"\s+fill="#d4d0c3"/m
    )
    [match[1].to_f, match[2].to_f]
  end

  def ghost_centres(html)
    html
      .scan(
        /<circle cx="(-?[\d.]+)" cy="(-?[\d.]+)" r="1" fill="none" stroke="#9c9188"/
      )
      .map { |x, y| [x.to_f, y.to_f] }
  end

  def shadow_radii(html)
    html
      .scan(/<circle\s+cx="0"\s+cy="0"\s+r="([\d.]+)"/m)
      .flatten
      .map(&:to_f)
      .uniq
      .sort
  end

  def view_box(html)
    html[/viewBox="([^"]+)"/, 1].split.map(&:to_f)
  end

  describe "the shadow it draws" do
    it "takes both radii from the geometry rather than the magnitudes" do
      html = render_disc(
        build_eclipse(
          geometry: build_geometry(
            axis_distance_km: 2401,
            position_angle: 208.22,
            umbra_km: 2 * moon_radius_km,
            penumbra_km: 4 * moon_radius_km
          ),
          umbral_magnitude: 99,
          penumbral_magnitude: 99
        ),
        detailed: true
      )

      expect(shadow_radii(html)).to eq([2.0, 4.0])
    end
  end

  describe "where it puts the Moon" do
    it "places it at its distance from the shadow axis" do
      html = render_disc(build_eclipse, detailed: true)
      x, y = moon_centre(html)

      expect(Math.hypot(x, y)).to be_within(0.001).of(2401 / moon_radius_km)
    end

    it "reads greatest eclipse as the axis to Moon direction" do
      html = render_disc(
        build_eclipse(
          geometry: build_geometry(axis_distance_km: 2 * moon_radius_km, position_angle: 0)
        ),
        detailed: true
      )

      expect(moon_centre(html)).to eq([0.0, -2.0])
    end

    it "puts a Moon east of the axis to the right" do
      html = render_disc(
        build_eclipse(
          geometry: build_geometry(axis_distance_km: 2 * moon_radius_km, position_angle: 90)
        ),
        detailed: true
      )

      expect(moon_centre(html)).to eq([2.0, 0.0])
    end
  end

  describe "the contact marks" do
    it "turns an external tangency away from the shadow axis" do
      html = render_disc(
        build_eclipse(
          penumbral: build_penumbral_phase(
            starting_geometry: build_geometry(
              axis_distance_km: 2 * moon_radius_km,
              position_angle: 0
            )
          )
        ),
        detailed: true
      )

      expect(ghost_centres(html).first).to eq([0.0, 2.0])
    end

    it "keeps an internal tangency facing the shadow axis" do
      html = render_disc(
        build_eclipse(
          total: build_total_phase(
            starting_geometry: build_geometry(
              axis_distance_km: 2 * moon_radius_km,
              position_angle: 0
            )
          )
        ),
        detailed: true
      )

      expect(ghost_centres(html)).to include([0.0, -2.0])
    end

    it "marks every contact of a total eclipse" do
      html = render_disc(build_eclipse, detailed: true)

      expect(ghost_centres(html).size).to eq(6)
    end

    it "marks only the penumbral contacts when there is no umbral phase" do
      html = render_disc(build_penumbral_eclipse, detailed: true)

      expect(ghost_centres(html).size).to eq(2)
    end

    it "marks the umbral but not the totality contacts for a partial" do
      html = render_disc(build_partial_eclipse, detailed: true)

      expect(ghost_centres(html).size).to eq(4)
    end

    it "lies on the path drawn between the penumbral contacts" do
      html = render_disc(build_eclipse, detailed: true)
      ends = ghost_centres(html).first(2)
      line = html.match(
        /<line\s+x1="(-?[\d.]+)"\s+y1="(-?[\d.]+)"\s+x2="(-?[\d.]+)"\s+y2="(-?[\d.]+)"/m
      )

      expect([[line[1].to_f, line[2].to_f], [line[3].to_f, line[4].to_f]])
        .to eq(ends)
    end

    it "keeps every contact on that path" do
      html = render_disc(build_eclipse, detailed: true)
      first, last = ghost_centres(html).first(2)
      run = [last.first - first.first, last.last - first.last]

      ghost_centres(html).drop(2).each do |x, y|
        cross = run.first * (y - first.last) - run.last * (x - first.first)
        expect(cross.abs / Math.hypot(*run)).to be < 0.05
      end
    end
  end

  describe "the compact figure" do
    it "frames the Moon in a square viewBox" do
      html = render_disc(build_eclipse)
      x, y, width, height = view_box(html)
      moon_x, moon_y = moon_centre(html)

      expect(width).to eq(height)
      expect(x + width / 2).to be_within(0.001).of(moon_x)
      expect(y + height / 2).to be_within(0.001).of(moon_y)
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
