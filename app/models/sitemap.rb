# frozen_string_literal: true

class Sitemap
  include Rails.application.routes.url_helpers

  def initialize(lunar_eclipse_years:)
    @lunar_eclipse_years = lunar_eclipse_years
  end

  def paths
    landing_paths + lunar_eclipse_archive_paths
  end

  private

  def landing_paths
    [
      root_path,
      almanac_path,
      moon_path,
      sun_path,
      lunar_eclipses_path,
      privacy_policy_path
    ]
  end

  def lunar_eclipse_archive_paths
    @lunar_eclipse_years
      .reject { |year| year == Time.current.year }
      .map { |year| lunar_eclipses_path(year: year) }
  end
end
