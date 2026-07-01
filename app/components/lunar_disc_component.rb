# frozen_string_literal: true

class LunarDiscComponent < ViewComponent::Base
  HIGHLAND_COLOR = "#d4d0c3"
  SHADE_COLOR = "#c4c0b2"
  MARE_COLOR = "#8b8980"
  HIGHLIGHT_COLOR = "#e7e3d6"
  CRATER_COLOR = "#f1ecdd"
  RAY_COLOR = "#ece7d9"
  SHADOW_COLOR = "#1a1a1a"
  RAY_OPACITY = 0.22
  OUTLINE_WIDTH = 2
  REFERENCE_DIAMETER = 0.5181
  MIN_SCALE = 0.9
  MAX_SCALE = 1.09

  EAST_SIGN = 1
  NORTH_SIGN = -1
  ORIENTATION_SIGN = 1
  SHADOW_BASE_OFFSET = 0

  FULL_MOON_THRESHOLD = 1
  NEW_MOON_THRESHOLD = 179

  def initialize(moon:, size: 120, options: {})
    @disc = moon.lunar_disc
    @phase_name = moon.current_phase_name
    @illuminated_percentage = (moon.illuminated_fraction * 100).round
    @angular_diameter = moon.angular_diameter
    @size = size
    @colors = default_colors.merge(options)
    @id = SecureRandom.hex(4)
  end

  private

  attr_reader :size

  def view_box_size
    size * 2
  end

  def center
    size.to_f
  end

  def radius
    (size * 0.9 * disc_scale) - (OUTLINE_WIDTH / 2.0)
  end

  def disc_scale
    (@angular_diameter.degrees / REFERENCE_DIAMETER).clamp(MIN_SCALE, MAX_SCALE)
  end

  def outline_width
    OUTLINE_WIDTH
  end

  def clip_id
    "lunar-disc-clip-#{@id}"
  end

  def title_id
    "lunar-disc-title-#{@id}"
  end

  def description_id
    "lunar-disc-description-#{@id}"
  end

  def accessible_title
    t("moon.disc.title")
  end

  def accessible_description
    t(
      "moon.disc.description",
      phase: t("moon.disc.phases.#{@phase_name}"),
      percentage: @illuminated_percentage,
      diameter: apparent_diameter
    )
  end

  def apparent_diameter
    "#{(@angular_diameter.degrees * 60).round(1)}′"
  end

  def orientation_transform
    rotation = (ORIENTATION_SIGN * @disc.orientation_angle.degrees).round(2)
    "rotate(#{rotation} #{center} #{center})"
  end

  def shadow_transform
    "rotate(#{shadow_rotation.round(2)} #{center} #{center})"
  end

  def visible_features
    @visible_features ||= @disc
      .projected_features
      .select(&:renderable?)
      .map { |feature| feature_drawing(feature) }
  end

  def feature_drawing(feature)
    points = screen_points(feature.points)
    ray = feature.kind == :ray
    {
      path: ray ? straight_path(points) : smooth_path(points),
      color: feature_color(feature.kind),
      opacity: ray ? RAY_OPACITY : 1
    }
  end

  def shadow_path
    phase_angle = @disc.terminator.phase_angle
    return "" if phase_angle.degrees < FULL_MOON_THRESHOLD
    return new_moon_path if phase_angle.degrees > NEW_MOON_THRESHOLD

    terminator_radius = radius * @disc.terminator.axis_ratio
    crescent = phase_angle.degrees > 90
    gibbous_flag = crescent ? 1 : 0
    terminator_direction = crescent ? 0 : 1

    [
      "M", center, top,
      "A", radius, radius, 0, 0, 0, center, bottom,
      "A", terminator_radius, radius, 0, gibbous_flag, terminator_direction,
      center, top
    ].join(" ")
  end

  def screen_points(points)
    points.map { |x, y| [screen_x(x), screen_y(y)] }
  end

  def smooth_path(points)
    count = points.size
    path = "M #{format_point(points.first)}"
    count.times do |index|
      previous = points[(index - 1) % count]
      current = points[index]
      following = points[(index + 1) % count]
      after = points[(index + 2) % count]
      control_one = catmull_rom_control(current, following, previous)
      control_two = catmull_rom_control(following, current, after)
      path << " C #{format_point(control_one)} " \
        "#{format_point(control_two)} #{format_point(following)}"
    end
    "#{path} Z"
  end

  def catmull_rom_control(anchor, toward, away)
    [
      anchor[0] + (toward[0] - away[0]) / 6.0,
      anchor[1] + (toward[1] - away[1]) / 6.0
    ]
  end

  def straight_path(points)
    "M #{points.map { |point| format_point(point) }.join(" L ")} Z"
  end

  def format_point(point)
    "#{point[0].round(2)},#{point[1].round(2)}"
  end

  def feature_color(kind)
    @colors.fetch(kind, @colors[:mare])
  end

  def screen_x(x)
    center + EAST_SIGN * x * radius
  end

  def screen_y(y)
    center + NORTH_SIGN * y * radius
  end

  def shadow_rotation
    angle = @disc.terminator.bright_limb_angle.radians
    screen_x_component = EAST_SIGN * Math.sin(angle)
    screen_y_component = NORTH_SIGN * Math.cos(angle)
    SHADOW_BASE_OFFSET +
      Math.atan2(screen_y_component, screen_x_component) * 180 / Math::PI
  end

  def new_moon_path
    "M #{center - radius},#{center} " \
      "a #{radius},#{radius} 0 1,0 #{radius * 2},0 " \
      "a #{radius},#{radius} 0 1,0 -#{radius * 2},0"
  end

  def top
    center - radius
  end

  def bottom
    center + radius
  end

  def default_colors
    {
      highland: HIGHLAND_COLOR,
      highland_shade: SHADE_COLOR,
      mare: MARE_COLOR,
      highland_light: HIGHLIGHT_COLOR,
      ray: RAY_COLOR,
      crater: CRATER_COLOR,
      shadow: SHADOW_COLOR
    }
  end
end
