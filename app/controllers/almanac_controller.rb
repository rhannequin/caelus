# frozen_string_literal: true

class AlmanacController < ApplicationController
  def show
    track_page_view("almanac")
  end
end
