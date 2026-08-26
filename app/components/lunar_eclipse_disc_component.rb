# frozen_string_literal: true

class LunarEclipseDiscComponent < ViewComponent::Base
  MOON_RADIUS_KM = Astronoby::Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

  MOON_COLOR = "#d4d0c3"
  MOON_EDGE_COLOR = "#f2eee2"
  GHOST_COLOR = "#9c9188"
  UMBRA_COLOR = "#2c1820"
  UMBRA_EDGE_COLOR = "#8a3a22"
  UMBRA_MOON_COLOR = "#9c4526"
  PENUMBRA_COLOR = "#4a3340"

  MARGIN = 0.35
  MOON_RADIUS = 1
  MOON_FRAME = 1.25
  LINE_WIDTH = 1.6

  EXTERNAL_TANGENCY_OFFSET = 180

  def initialize(lunar_eclipse:, size: 160, detailed: false)
    @lunar_eclipse = lunar_eclipse
    @size = size
    @detailed = detailed
    @id = SecureRandom.hex(4)
  end

  private

  attr_reader :lunar_eclipse, :size

  def detailed?
    @detailed
  end

  def width
    size
  end

  def height
    (size * view_box_height / view_box_width).round
  end

  def view_box
    if detailed?
      [bounds.first, bounds.second, view_box_width, view_box_height]
    else
      [
        moon_x - MOON_FRAME,
        moon_y - MOON_FRAME,
        view_box_width,
        view_box_height
      ]
    end.map { |value| round(value) }.join(" ")
  end

  def view_box_width
    detailed? ? bounds.third - bounds.first : MOON_FRAME * 2
  end

  def view_box_height
    detailed? ? bounds.fourth - bounds.second : MOON_FRAME * 2
  end

  # The Moon leaves the shadow further along its path than it entered, so the
  # figure is framed on what it actually draws rather than on the shadow.
  def bounds
    @bounds ||= begin
      discs = ([moon_position] + ghost_positions).map do |x, y|
        [
          x - MOON_RADIUS,
          y - MOON_RADIUS,
          x + MOON_RADIUS,
          y + MOON_RADIUS
        ]
      end
      boxes = discs << [
        -penumbra_radius,
        -penumbra_radius,
        penumbra_radius,
        penumbra_radius
      ]

      [
        boxes.map(&:first).min - MARGIN,
        boxes.map(&:second).min - MARGIN,
        boxes.map(&:third).max + MARGIN,
        boxes.map(&:fourth).max + MARGIN
      ]
    end
  end

  def umbra_radius
    @umbra_radius ||= in_moon_radii(geometry.umbra_radius)
  end

  def penumbra_radius
    @penumbra_radius ||= in_moon_radii(geometry.penumbra_radius)
  end

  def geometry
    lunar_eclipse.geometry
  end

  def in_moon_radii(distance)
    distance.km / MOON_RADIUS_KM
  end

  def moon_position
    @moon_position ||= position_of(geometry)
  end

  def moon_x
    moon_position.first
  end

  def moon_y
    moon_position.last
  end

  def position_of(contact_geometry, external_tangency: false)
    degrees = contact_geometry.position_angle.degrees
    degrees += EXTERNAL_TANGENCY_OFFSET if external_tangency
    angle = Astronoby::Angle.from_degrees(degrees)
    distance = in_moon_radii(contact_geometry.axis_distance)

    [distance * angle.sin, -distance * angle.cos]
  end

  def contact_geometries
    return [] unless detailed?

    umbral = lunar_eclipse.partial
    totality = lunar_eclipse.total

    [
      [lunar_eclipse.penumbral.starting_geometry, true],
      [lunar_eclipse.penumbral.ending_geometry, true],
      ([umbral.starting_geometry, true] if umbral),
      ([umbral.ending_geometry, true] if umbral),
      ([totality.starting_geometry, false] if totality),
      ([totality.ending_geometry, false] if totality)
    ].compact
  end

  def ghost_positions
    @ghost_positions ||= contact_geometries.map do |contact, external|
      position_of(contact, external_tangency: external)
    end
  end

  def path_ends
    ghost_positions.first(2)
  end

  def round(value)
    value.round(4)
  end

  def moon_color
    MOON_COLOR
  end

  def moon_edge_color
    MOON_EDGE_COLOR
  end

  def ghost_color
    GHOST_COLOR
  end

  def umbra_color
    UMBRA_COLOR
  end

  def umbra_edge_color
    UMBRA_EDGE_COLOR
  end

  def umbra_moon_color
    UMBRA_MOON_COLOR
  end

  def penumbra_color
    PENUMBRA_COLOR
  end

  def stroke_width
    @stroke_width ||= round(view_box_width / size * LINE_WIDTH)
  end

  def moon_stroke_width
    round(stroke_width * 1.5)
  end

  def moon_radius
    MOON_RADIUS
  end

  def penumbra_gradient_id
    "eclipse-penumbra-#{@id}"
  end

  def moon_clip_id
    "eclipse-moon-clip-#{@id}"
  end

  def title_id
    "eclipse-disc-title-#{@id}"
  end

  def description_id
    "eclipse-disc-description-#{@id}"
  end

  def accessible_title
    t("lunar_eclipses.disc.title")
  end

  def accessible_description
    t(
      "lunar_eclipses.disc.description",
      kind: t("lunar_eclipses.kinds.#{lunar_eclipse.kind}.name"),
      distance: helpers.format_number(
        in_moon_radii(geometry.axis_distance),
        precision: 2
      ),
      direction: t("lunar_eclipses.disc.#{hemisphere}"),
      umbral: umbral_immersion,
      penumbral: helpers.number_to_percentage(
        lunar_eclipse.penumbral_magnitude * 100,
        precision: 0
      )
    )
  end

  def hemisphere
    lunar_eclipse.gamma.negative? ? :south : :north
  end

  def umbral_immersion
    if lunar_eclipse.penumbral?
      t("lunar_eclipses.disc.outside_umbra")
    else
      helpers.number_to_percentage(
        lunar_eclipse.umbral_magnitude * 100,
        precision: 0
      )
    end
  end
end
