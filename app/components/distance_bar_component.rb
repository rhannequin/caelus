# frozen_string_literal: true

class DistanceBarComponent < ViewComponent::Base
  def initialize(
    start_distance:,
    current_distance:,
    end_distance:,
    start_distance_title:,
    end_distance_title:
  )
    @start_distance = start_distance
    @current_distance = current_distance
    @end_distance = end_distance
    @start_distance_title = start_distance_title
    @end_distance_title = end_distance_title
  end

  private

  def percentage
    ((@current_distance - @start_distance).to_f / (@end_distance - @start_distance) * 100)
      .clamp(0, 100)
      .round(2)
  end
end
