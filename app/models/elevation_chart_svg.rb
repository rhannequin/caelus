# frozen_string_literal: true

class ElevationChartSvg
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
    @elevation_data = @elevations.data
    @current_position = current_position
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def generate
    calculate_dimensions
    calculate_statistics
    build_svg
  end

  def draw
    generate.html_safe
  end

  private

  def calculate_dimensions
    @width = @options[:width]
    @height = @options[:height]
    @min_y = @options[:padding_top]
    @max_y = @height - @options[:padding_bottom]
  end

  def calculate_statistics
    @min_elevation = @elevations.minimum.elevation
    @max_elevation = @elevations.maximum.elevation
    @current_elevation = @current_position.elevation
    @elevation_range = @max_elevation - @min_elevation
  end

  def build_svg
    <<~SVG
      <svg
        width="100%"
        height="#{@height}"
        viewBox="0 0 #{@width} #{@height}"
        preserveAspectRatio="xMidYMid meet"
      >
        #{build_definitions}
        #{build_grid}
        #{build_elevation_area}
        #{build_elevation_line}
        #{build_current_day_marker}
        #{build_season_labels}
      </svg>
    SVG
  end

  def build_definitions
    <<~DEFS
      <defs>
        <linearGradient
          id="elevationGradient"
          x1="0%" y1="0%" x2="0%" y2="100%"
        >
          <stop 
            offset="0%"
            style="stop-color:#{@options[:colors][:fill_start]};stop-opacity:0.3"
          />
          <stop
            offset="100%"
            style="stop-color:#{@options[:colors][:fill_end]};stop-opacity:0.05"
          />
        </linearGradient>
      </defs>
    DEFS
  end

  def build_grid
    grid_lines = []

    # Horizontal grid lines
    (1..3).each do |i|
      y = @min_y + (@max_y - @min_y) * i / 4.0
      grid_lines << %(<line x1="0" y1="#{y}" x2="#{@width}" y2="#{y}"/>)
    end

    # Vertical grid lines (seasons)
    [91, 182, 273].each do |x|
      grid_lines << %(<line x1="#{x}" y1="0" x2="#{x}" y2="#{@height}"/>)
    end

    <<~GRID
      <g
        stroke="#{@options[:colors][:grid]}"
        stroke-width="0.5"
        opacity="#{@options[:grid_opacity]}"
      >
        #{grid_lines.join("\n")}
      </g>
    GRID
  end

  def build_elevation_area
    path_d = build_elevation_path
    area_path = "#{path_d} L#{@width},#{@max_y} L0,#{@max_y} Z"

    %(
        <path
          d="#{area_path}"
          fill="url(#elevationGradient)"
          opacity="#{@options[:fill_opacity]}"
        />
      )
  end

  def build_elevation_line
    path_d = build_elevation_path

    %(
        <path
          d="#{path_d}"
          stroke="#{@options[:colors][:stroke]}"
          stroke-width="#{@options[:stroke_width]}"
          fill="none"
        />
      )
  end

  def build_elevation_path
    return "" if @elevation_data.empty? || @elevation_range.zero?

    path_points = @elevation_data.map do |point|
      x = point.yday - 1
      y = scale_elevation_to_y(point.elevation)
      "#{x},#{y.round(1)}"
    end.join(" L")

    "M #{path_points}"
  end

  def build_current_day_marker
    current_x = @current_position.yday - 1
    current_y = scale_elevation_to_y(@current_elevation)

    <<~MARKER
      <line
        x1="#{current_x}"
        y1="0"
        x2="#{current_x}"
        y2="#{@height}"
        stroke="#{@options[:colors][:marker]}"
        stroke-width="#{@options[:stroke_width]}"
        opacity="#{@options[:marker_opacity]}"
      />
      <circle
        cx="#{current_x}"
        cy="#{current_y.round(1)}"
        r="#{@options[:marker_radius]}"
        fill="#{@options[:colors][:marker]}"
      />
    MARKER
  end

  def build_season_labels
    labels = [
      {x: 5, text: I18n.t("date.abbr_month_names")[1]},
      {x: 86, text: I18n.t("date.abbr_month_names")[4]},
      {x: 177, text: I18n.t("date.abbr_month_names")[7]},
      {x: 268, text: I18n.t("date.abbr_month_names")[10]},
      {x: 340, text: I18n.t("date.abbr_month_names")[12]}
    ]

    labels.map do |label|
      %(
          <text
            x="#{label[:x]}"
            y="195"
            class="text-xs fill-current opacity-60"
          >
            #{label[:text]}
          </text>
        )
    end.join("\n")
  end

  def scale_elevation_to_y(elevation)
    return @max_y if @elevation_range.zero?

    term1 = (elevation - @min_elevation).degrees / @elevation_range.degrees
    @max_y - (term1 * (@max_y - @min_y))
  end
end
