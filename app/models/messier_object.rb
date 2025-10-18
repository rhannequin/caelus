# frozen_string_literal: true

class MessierObject
  include ActiveModel::Model

  NAKED_EYE_MAGNITUDE_LIMIT = 4
  BINOCULARS_MAGNITUDE_LIMIT = 6

  attr_accessor :number,
    :ngc_number,
    :name,
    :type,
    :constellation,
    :magnitude,
    :size,
    :j2000_coordinates,
    :distance

  def at(time, observer:, use_ephem: false)
    MessierObjectPosition.new(
      messier_object: self,
      time: time,
      observer: observer,
      use_ephem: use_ephem
    )
  end

  def messier_number
    "M#{number}"
  end

  def deep_sky_object
    @deep_sky_object ||=
      Astronoby::DeepSkyObject.new(equatorial_coordinates: j2000_coordinates)
  end

  def visible_with
    if magnitude <= NAKED_EYE_MAGNITUDE_LIMIT
      I18n.t("messier.tool.naked_eye")
    elsif magnitude >= BINOCULARS_MAGNITUDE_LIMIT
      I18n.t("messier.tool.telescope")
    else
      I18n.t("messier.tool.binoculars")
    end
  end
end
