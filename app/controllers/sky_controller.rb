# frozen_string_literal: true

class SkyController < ApplicationController
  def show
    @sky_map = SkyMap.new(observer: @observer, time: @time)

    track_page_view("sky")
  end
end
