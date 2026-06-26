# frozen_string_literal: true

class ElevationChartComponent < ViewComponent::Base
  DEFAULT_OPTIONS = {
    width: 365,
    height: 200,
    padding_top: 20,
    padding_bottom: 40,
    stroke_width: 2,
    grid_opacity: 0.1,
    fill_opacity: 0.6,
    marker_opacity: 0.7,
    marker_radius: 4,
    colors: {
      stroke: "#FFA000",
      fill_start: "#FDB813",
      fill_end: "#FDB813",
      marker: "#FDB813",
      grid: "currentColor"
    }
  }.freeze

  def initialize(elevations:, current_position:, options: {})
    @elevations = elevations
    @elevation_data = elevations.data
    @current_position = current_position
    @options = DEFAULT_OPTIONS.merge(options)
    @min_elevation = elevations.minimum.elevation
    @max_elevation = elevations.maximum.elevation
    @current_elevation = current_position.elevation
    @elevation_range = @max_elevation - @min_elevation
  end

  private

  def width
    @options[:width]
  end

  def height
    @options[:height]
  end

  def min_y
    @options[:padding_top]
  end

  def max_y
    height - @options[:padding_bottom]
  end

  def stroke_width
    @options[:stroke_width]
  end

  def grid_opacity
    @options[:grid_opacity]
  end

  def fill_opacity
    @options[:fill_opacity]
  end

  def marker_opacity
    @options[:marker_opacity]
  end

  def marker_radius
    @options[:marker_radius]
  end

  def stroke_color
    @options.dig(:colors, :stroke)
  end

  def fill_start_color
    @options.dig(:colors, :fill_start)
  end

  def fill_end_color
    @options.dig(:colors, :fill_end)
  end

  def marker_color
    @options.dig(:colors, :marker)
  end

  def grid_color
    @options.dig(:colors, :grid)
  end

  def horizontal_grid_lines
    (1..3).map { |i| min_y + (max_y - min_y) * i / 4.0 }
  end

  def vertical_grid_lines
    [91, 182, 273]
  end

  def elevation_path
    return "" if @elevation_data.empty? || @elevation_range.zero?

    path_points = @elevation_data.map do |point|
      "#{point.yday - 1},#{scale_elevation_to_y(point.elevation).round(1)}"
    end.join(" L")

    "M #{path_points}"
  end

  def area_path
    "#{elevation_path} L#{width},#{max_y} L0,#{max_y} Z"
  end

  def current_x
    @current_position.yday - 1
  end

  def current_y
    scale_elevation_to_y(@current_elevation).round(1)
  end

  def season_labels
    month_names = I18n.t("date.abbr_month_names")
    [
      {x: 5, text: month_names[1]},
      {x: 86, text: month_names[4]},
      {x: 177, text: month_names[7]},
      {x: 268, text: month_names[10]},
      {x: 340, text: month_names[12]}
    ]
  end

  def scale_elevation_to_y(elevation)
    return max_y if @elevation_range.zero?

    ratio = (elevation - @min_elevation).degrees / @elevation_range.degrees
    max_y - (ratio * (max_y - min_y))
  end
end
