# frozen_string_literal: true

class DeepSkyObject
  include ActiveModel::Model

  DEFAULT_INSTRUMENT = :small_telescope

  DIFFUSE_TYPES = [
    :spiral_galaxy,
    :elliptical_galaxy,
    :irregular_galaxy,
    :lenticular_galaxy,
    :nebula,
    :reflection_nebula,
    :planetary_nebula,
    :supernova_remnant
  ].freeze

  attr_accessor :number,
    :catalog,
    :notability,
    :instrument,
    :ngc_number,
    :name,
    :type,
    :constellation,
    :magnitude,
    :major_axis,
    :minor_axis,
    :j2000_coordinates,
    :distance

  def at(time, observer:, use_ephem: false, night: nil)
    DeepSkyObjectPosition.new(
      deep_sky_object: self,
      time: time,
      observer: observer,
      use_ephem: use_ephem,
      night: night
    )
  end

  def designation
    DeepSkyObjectsCatalog.designation_for(catalog, number)
  end

  def astronoby_deep_sky_object
    @astronoby_deep_sky_object ||=
      Astronoby::DeepSkyObject.new(equatorial_coordinates: j2000_coordinates)
  end

  def circular?
    major_axis == minor_axis
  end

  def diffuse?
    DIFFUSE_TYPES.include?(type)
  end

  def apparent_area
    Math::PI / 4 * arcseconds(major_axis) * arcseconds(minor_axis)
  end

  def surface_brightness
    return unless diffuse?

    magnitude + 2.5 * Math.log10(apparent_area)
  end

  def visible_with
    I18n.t("deep_sky.tool.#{instrument || DEFAULT_INSTRUMENT}")
  end

  private

  def arcseconds(angle)
    angle.degrees * 3600
  end
end
