# frozen_string_literal: true

class ConjunctionSkyComponent < ViewComponent::Base
  WIDTH = 440
  HEIGHT = 300
  SIDE_PADDING = 30
  TOP_PADDING = 66
  BOTTOM_PADDING = 52

  BREATHING_ROOM = 1.12
  MINIMUM_FIELD_OF_VIEW = 0.05

  BRIGHTEST_RADIUS = 4.0
  MAGNITUDE_SPREAD = 0.7
  MINIMUM_MARKER_RADIUS = 2.0
  MAXIMUM_MARKER_RADIUS = 6.0

  LABEL_GAP = 16
  NORTH_ARROW_LENGTH = 26
  NORTH_ARROW_LABEL = 36

  MOON_DISC_RATIO = 0.9
  MOON_OUTLINE_WIDTH = 1.0
  MOON_OUTLINE_COLOR = "rgba(255, 255, 255, 0.45)"
  MOON_SHADOW_COLOR = "#161a2c"

  SCALE_STEPS_IN_ARCMINUTES = [1, 2, 5, 10, 15, 30, 60, 120, 300, 600].freeze

  def initialize(conjunction:)
    @conjunction = conjunction
  end

  private

  attr_reader :conjunction

  def horizon_view?
    conjunction.visible?
  end

  def apparition
    conjunction.closest_apparition
  end

  def view_bodies
    @view_bodies ||= if horizon_view?
      conjunction.observed_pair
    else
      conjunction.bodies
    end
  end

  def view_primary
    view_bodies.first
  end

  def view_secondary
    view_bodies.second
  end

  def view_angle
    @view_angle ||= if horizon_view?
      conjunction.observed_position_angle.radians - rotation
    else
      conjunction.position_angle.radians
    end
  end

  def separation_degrees
    @separation_degrees ||= if horizon_view?
      conjunction.observed_separation.degrees
    else
      conjunction.separation.degrees
    end
  end

  def primary_point
    @primary_point ||= point_at(-1)
  end

  def secondary_point
    @secondary_point ||= point_at(1)
  end

  def point_at(side)
    [
      center_x + side * half_gap * east_west,
      center_y + side * half_gap * north_south
    ]
  end

  def east_west
    @east_west ||= -Math.sin(view_angle)
  end

  def north_south
    @north_south ||= -Math.cos(view_angle)
  end

  def half_gap
    separation_degrees * pixels_per_degree / 2
  end

  def center_x
    WIDTH / 2.0
  end

  def center_y
    TOP_PADDING + usable_height / 2.0
  end

  def usable_width
    WIDTH - 2 * SIDE_PADDING
  end

  def usable_height
    HEIGHT - TOP_PADDING - BOTTOM_PADDING
  end

  def pixels_per_degree
    @pixels_per_degree ||= [
      usable_width / span_degrees(east_west),
      usable_height / span_degrees(north_south)
    ].min
  end

  def span_degrees(axis)
    span = (separation_degrees * axis.abs + disc_degrees) * BREATHING_ROOM

    [span, MINIMUM_FIELD_OF_VIEW].max
  end

  def disc_degrees
    moon? ? view_primary.angular_diameter.degrees : 0
  end

  def moon?
    conjunction.moon?
  end

  def field_of_view
    usable_width / pixels_per_degree
  end

  def moon_radius
    disc_degrees * pixels_per_degree / 2
  end

  def moon_disc_size
    (moon_radius + MOON_OUTLINE_WIDTH / 2) / MOON_DISC_RATIO
  end

  def moon_disc_options
    {
      outline_width: MOON_OUTLINE_WIDTH,
      outline_color: MOON_OUTLINE_COLOR,
      shadow_color: MOON_SHADOW_COLOR
    }
  end

  def moon_disc_offset
    [
      primary_point.first - moon_disc_size,
      primary_point.second - moon_disc_size
    ]
  end

  def moon_rotation
    bright_limb = view_primary.bright_limb_position_angle.radians - rotation
    degrees = Math.atan2(
      -Math.cos(bright_limb),
      -Math.sin(bright_limb)
    ) * 180 / Math::PI

    waxing? ? degrees : degrees + 180
  end

  def waxing?
    view_primary.age <= Moon::HALF_SYNODIC_PERIOD
  end

  def rotation
    horizon_view? ? conjunction.parallactic_angle.radians : 0
  end

  def north_rotation
    conjunction.parallactic_angle.degrees
  end

  def north_anchor
    [WIDTH - 52, 48]
  end

  def north_label_point
    [
      north_anchor.first + Math.sin(rotation) * NORTH_ARROW_LABEL,
      north_anchor.second - Math.cos(rotation) * NORTH_ARROW_LABEL
    ]
  end

  def marker_radius(body)
    (BRIGHTEST_RADIUS - MAGNITUDE_SPREAD * body.magnitude)
      .clamp(MINIMUM_MARKER_RADIUS, MAXIMUM_MARKER_RADIUS)
  end

  def primary_radius
    moon? ? moon_radius : marker_radius(view_primary)
  end

  def secondary_radius
    marker_radius(view_secondary)
  end

  def bodies_overlap?
    half_gap * 2 < primary_radius + secondary_radius
  end

  def primary_label_point
    label_point(primary_point, primary_radius, -1)
  end

  def secondary_label_point
    label_point(secondary_point, secondary_radius, 1)
  end

  def label_point(point, radius, side)
    distance = radius + LABEL_GAP

    [
      (point.first + side * distance * east_west)
        .clamp(SIDE_PADDING, WIDTH - SIDE_PADDING),
      (point.second + side * distance * north_south)
        .clamp(TOP_PADDING / 2.0, HEIGHT - BOTTOM_PADDING / 2.0)
    ]
  end

  def body_name(body)
    body.class.planet_name
  end

  def body_color(body)
    body.class.color
  end

  def scale_arcminutes
    @scale_arcminutes ||= SCALE_STEPS_IN_ARCMINUTES
      .select { |step| step <= field_of_view * 60 / 3 }
      .max || SCALE_STEPS_IN_ARCMINUTES.first
  end

  def scale_pixels
    scale_arcminutes / 60.0 * pixels_per_degree
  end

  def scale_label
    if scale_arcminutes < 60
      t("conjunctions.sky.scale_arcminutes", count: scale_arcminutes)
    else
      t("conjunctions.sky.scale_degrees", count: scale_arcminutes / 60)
    end
  end

  def scale_y
    HEIGHT - BOTTOM_PADDING / 2.0
  end

  def separation_text
    helpers.conjunction_separation(
      horizon_view? ? conjunction.observed_separation : conjunction.separation
    )
  end

  def vantage_text
    t(
      "conjunctions.sky.vantage",
      time: l(apparition.time.in_time_zone, format: :hm),
      altitude: helpers.format_number(
        apparition.altitude.degrees,
        unit: :degree,
        precision: 0
      ),
      direction: helpers.cardinal_direction(apparition.azimuth.degrees)
    )
  end

  def description
    t(
      "conjunctions.sky.description",
      primary: body_name(view_primary),
      secondary: body_name(view_secondary),
      separation: separation_text
    )
  end
end
