# frozen_string_literal: true

module DeepSkyHelper
  MOON_PROXIMITY_LIMIT = Astronoby::Angle.from_degrees(20)

  def near_moon?(messier_object_position)
    separation = messier_object_position.moon_separation

    !separation.nil? && separation <= MOON_PROXIMITY_LIMIT
  end

  def messier_look_for(messier_object)
    I18n.t("messier.look_for.#{messier_object.number}", default: nil).presence
  end
end
