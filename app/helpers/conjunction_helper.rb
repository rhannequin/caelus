# frozen_string_literal: true

module ConjunctionHelper
  NEARBY_AU = 0.01
  PHASE_THRESHOLD = 99
  SKY_DIRECTIONS = %w[
    north
    north_east
    east
    south_east
    south
    south_west
    west
    north_west
  ].freeze

  def conjunction_separation(angle)
    if angle.degrees < 1
      format_number(angle.degrees * 60, unit: :arcminute, precision: 1)
    else
      format_number(angle.degrees, unit: :degree, precision: 2)
    end
  end

  def conjunction_relative_direction(position_angle)
    index = ((position_angle.degrees % 360) / 45).round % SKY_DIRECTIONS.size

    t("cardinal_direction.#{SKY_DIRECTIONS[index]}")
  end

  def conjunction_distance(distance)
    if distance.au < NEARBY_AU
      format_number(distance.km, unit: :km, precision: 0)
    else
      format_number(distance.au, unit: :au, precision: 3)
    end
  end

  def conjunction_angular_diameter(angle)
    arcseconds = angle.degrees * 3600

    if arcseconds >= 60
      format_number(arcseconds / 60, unit: :arcminute, precision: 1)
    else
      format_number(arcseconds, unit: :arcsecond, precision: 0)
    end
  end

  def conjunction_magnitude(magnitude)
    formatted = format_number(magnitude, precision: 2)

    magnitude.negative? ? formatted : "+#{formatted}"
  end

  def conjunction_shows_illumination?(body)
    body.is_a?(Moon) || body.illuminated_percentage < PHASE_THRESHOLD
  end

  def conjunction_body_name(body)
    body.class.planet_name
  end

  def conjunction_title(conjunction)
    celestial_event_title(conjunction.celestial_event)
  end
end
