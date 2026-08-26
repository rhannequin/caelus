# frozen_string_literal: true

class LunarEclipseDiscComponent < ViewComponent::Base
  MOON_RADIUS_KM = 1737.4

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
      [-half_width, -half_height, view_box_width, view_box_height]
    else
      [-MOON_FRAME, moon_y - MOON_FRAME, view_box_width, view_box_height]
    end.map { |value| round(value) }.join(" ")
  end

  def view_box_width
    detailed? ? half_width * 2 : MOON_FRAME * 2
  end

  def view_box_height
    detailed? ? half_height * 2 : MOON_FRAME * 2
  end

  def half_height
    @half_height ||=
      [penumbra_radius, axis_distance + MOON_RADIUS].max + MARGIN
  end

  def half_width
    @half_width ||= [
      half_height,
      contact_offsets.max.to_f + MOON_RADIUS + MARGIN
    ].max
  end

  def axis_distance
    @axis_distance ||= lunar_eclipse.shadow_axis_distance.km / MOON_RADIUS_KM
  end

  def umbra_radius
    @umbra_radius ||= shadow_radius(lunar_eclipse.umbral_magnitude)
  end

  def penumbra_radius
    @penumbra_radius ||= shadow_radius(lunar_eclipse.penumbral_magnitude)
  end

  def shadow_radius(magnitude)
    [2 * magnitude * MOON_RADIUS - MOON_RADIUS + axis_distance, 0].max
  end

  def moon_y
    @moon_y ||=
      lunar_eclipse.gamma.negative? ? axis_distance : -axis_distance
  end

  def contact_offsets
    return [] unless detailed?

    @contact_offsets ||= [
      penumbra_radius + MOON_RADIUS,
      (umbra_radius + MOON_RADIUS if lunar_eclipse.partial),
      (umbra_radius - MOON_RADIUS if lunar_eclipse.total)
    ].compact
      .filter_map { |distance| half_chord(distance) }
      .flat_map { |offset| [-offset, offset] }
  end

  def half_chord(distance)
    squared = distance**2 - axis_distance**2
    Math.sqrt(squared) if squared.positive?
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
      distance: helpers.format_number(axis_distance, precision: 2),
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
