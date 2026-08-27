# frozen_string_literal: true

class MessierObject
  include ActiveModel::Model

  DEFAULT_INSTRUMENT = :small_telescope

  attr_accessor :number,
    :notability,
    :instrument,
    :ngc_number,
    :name,
    :type,
    :constellation,
    :magnitude,
    :size,
    :j2000_coordinates,
    :distance

  def at(time, observer:, use_ephem: false, night: nil)
    MessierObjectPosition.new(
      messier_object: self,
      time: time,
      observer: observer,
      use_ephem: use_ephem,
      night: night
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
    I18n.t("messier.tool.#{instrument || DEFAULT_INSTRUMENT}")
  end
end
