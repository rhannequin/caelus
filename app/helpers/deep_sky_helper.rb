# frozen_string_literal: true

module DeepSkyHelper
  MOON_PROXIMITY_LIMIT = Astronoby::Angle.from_degrees(20)

  def near_moon?(deep_sky_object_position)
    separation = deep_sky_object_position.moon_separation

    !separation.nil? && separation <= MOON_PROXIMITY_LIMIT
  end

  def apparent_size(deep_sky_object)
    major = arcminutes_label(deep_sky_object.major_axis)
    return major if deep_sky_object.circular?

    "#{major} × #{arcminutes_label(deep_sky_object.minor_axis)}"
  end

  def surface_brightness_label(deep_sky_object)
    surface_brightness = deep_sky_object.surface_brightness
    return unless surface_brightness

    t(
      "deep_sky.surface_brightness_value",
      value: format_number(surface_brightness, precision: 1)
    )
  end

  def deep_sky_look_for(deep_sky_object)
    I18n.t(
      "deep_sky.look_for.#{deep_sky_object.designation}",
      default: nil
    ).presence
  end

  private

  def arcminutes_label(angle)
    arcminutes = angle.degrees * 60
    precision = (arcminutes.round(1) == arcminutes.round) ? 0 : 1

    format_number(arcminutes, unit: :arcminute, precision: precision)
  end
end
