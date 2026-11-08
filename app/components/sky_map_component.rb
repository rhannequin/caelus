# frozen_string_literal: true

class SkyMapComponent < ViewComponent::Base
  def initialize(sky_map:)
    @sky_map = sky_map
  end

  private

  attr_reader :sky_map
end
