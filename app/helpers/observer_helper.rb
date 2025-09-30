# frozen_string_literal: true

module ObserverHelper
  def format_observer_coordinates(observer)
    latitude = observer.latitude.degrees
    longitude = observer.longitude.degrees
    latitude_cardinal = if latitude >= 0
      I18n.t("cardinal_direction.north")
    else
      I18n.t("cardinal_direction.south")
    end
    longitude_cardinal = if longitude >= 0
      I18n.t("cardinal_direction.east")
    else
      I18n.t("cardinal_direction.west")
    end
    [
      format("%.2f° %s", latitude.abs, latitude_cardinal),
      format("%.2f° %s", longitude.abs, longitude_cardinal)
    ].join(", ")
  end

  def cardinal_direction(degrees)
    directions = %w[
      north
      north_east
      east
      south_east
      south
      south_west
      west
      north_west
    ]
    index = ((degrees % 360) / 45).to_i % 8
    I18n.t("cardinal_direction.with_symbols.#{directions[index]}")
  end
end
