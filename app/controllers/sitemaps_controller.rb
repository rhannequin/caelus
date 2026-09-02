# frozen_string_literal: true

class SitemapsController < ApplicationController
  def show
    @sitemap = Sitemap.new(
      lunar_eclipse_years: LunarEclipsesController::SUPPORTED_YEARS
    )

    expires_in 1.day
  end
end
