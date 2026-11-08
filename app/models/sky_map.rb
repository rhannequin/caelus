# frozen_string_literal: true

class SkyMap
  SIZE = 800
  PADDING = 24
  STAR_MAGNITUDE_LIMIT = 4.5

  def initialize(observer:, time:)
    @observer = observer
    @time = time
  end

  def svg
    chart.render(*layers)
  end

  private

  def chart
    Skymap::Chart.new(
      observer: @observer,
      instant: Astronoby::Instant.from_time(@time),
      canvas: Skymap::Canvas.new(size: SIZE, padding: PADDING)
    )
  end

  def layers
    [
      Skymap::Layers::Ecliptic.new,
      Skymap::Layers::ConstellationLines.new(
        lines: SkyCatalogs.main_constellation_lines,
        stars: SkyCatalogs.stars
      ),
      Skymap::Layers::Stars.new(
        stars: SkyCatalogs.stars,
        magnitude_limit: STAR_MAGNITUDE_LIMIT
      ),
      Skymap::Layers::ConstellationNames.new(
        lines: SkyCatalogs.constellation_lines,
        stars: SkyCatalogs.stars
      ),
      Skymap::Layers::Planets.new(ephem: ephem, labels: true),
      Skymap::Layers::Sun.new(ephem: ephem),
      Skymap::Layers::Moon.new(ephem: ephem),
      Skymap::Layers::CardinalDirections.new
    ]
  end

  def ephem
    @ephem ||= SPK.for_time(@time)
  end
end
