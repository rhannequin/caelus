# frozen_string_literal: true

class MoonPhaseComponent < ViewComponent::Base
  SYNODIC_MONTH_DAYS = 29.530588853
  HALF_SYNODIC_PERIOD = SYNODIC_MONTH_DAYS / 2.0
  DEFAULT_MOON_COLOR = "#faf8f0"
  DEFAULT_SHADOW_COLOR = "#1a1a1a"
  DEFAULT_OUTLINE_COLOR = "#666"
  DEFAULT_OUTLINE_WIDTH = 2

  def initialize(moon:, size: 200, options: {})
    @phase_angle = moon.phase_angle
    @age = moon.age
    @size = size
    @options = default_options.merge(options)
    @is_waxing = @age <= HALF_SYNODIC_PERIOD
  end

  private

  def view_box_size
    @size * 2
  end

  def center_x
    @size.to_f
  end

  def center_y
    @size.to_f
  end

  def radius
    (@size * 0.9) - (@options[:outline_width].to_f / 2)
  end

  def moon_color
    @options[:moon_color]
  end

  def shadow_color
    @options[:shadow_color]
  end

  def outline_color
    @options[:outline_color]
  end

  def outline_width
    @options[:outline_width]
  end

  def shadow_path
    @shadow_path ||= calculate_shadow_path
  end

  def default_options
    {
      moon_color: DEFAULT_MOON_COLOR,
      shadow_color: DEFAULT_SHADOW_COLOR,
      outline_color: DEFAULT_OUTLINE_COLOR,
      outline_width: DEFAULT_OUTLINE_WIDTH
    }
  end

  def calculate_shadow_path
    return "" if @phase_angle.degrees < 1 # Full moon

    if @phase_angle.degrees > 179 # New moon
      return "M #{center_x - radius},#{center_y} a #{radius},#{radius} " \
        "0 1,0 #{radius * 2},0 a #{radius},#{radius} 0 1,0 -#{radius * 2},0"
    end

    terminator_radius_x = (radius * @phase_angle.cos).abs
    crescent_moon = @phase_angle.degrees > 90
    shadow_hemisphere = @is_waxing ? 0 : 1
    shadow_gibbous = crescent_moon ? 1 : 0
    terminator_direction =
      crescent_moon ? shadow_hemisphere : (1 - shadow_hemisphere)

    top_y = center_y - radius
    bottom_y = center_y + radius

    [
      "M",
      center_x,
      top_y,
      "A",
      radius,
      radius,
      0,
      0,
      shadow_hemisphere,
      center_x,
      bottom_y,
      "A",
      terminator_radius_x,
      radius,
      0,
      shadow_gibbous,
      terminator_direction,
      center_x,
      top_y
    ].join(" ")
  end
end
