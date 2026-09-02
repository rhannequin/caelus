# frozen_string_literal: true

module LunarEclipseHelper
  HorizonEvent = Struct.new(:name, :time)

  def lunar_eclipse_contacts(lunar_eclipse, observer)
    penumbral = lunar_eclipse.penumbral
    umbral = lunar_eclipse.partial
    totality = lunar_eclipse.total

    [
      [:p1, penumbral.starting_instant, penumbral.starting_geometry],
      ([:u1, umbral.starting_instant, umbral.starting_geometry] if umbral),
      ([:u2, totality.starting_instant, totality.starting_geometry] if totality),
      [:greatest, lunar_eclipse.instant, lunar_eclipse.geometry],
      ([:u3, totality.ending_instant, totality.ending_geometry] if totality),
      ([:u4, umbral.ending_instant, umbral.ending_geometry] if umbral),
      [:p4, penumbral.ending_instant, penumbral.ending_geometry]
    ].compact.map do |key, instant, geometry|
      LunarEclipseContact.new(
        key: key,
        instant: instant,
        geometry: geometry,
        observer: observer
      )
    end
  end

  def lunar_eclipse_phases(lunar_eclipse)
    [
      [:penumbral, lunar_eclipse.penumbral],
      [:partial, lunar_eclipse.partial],
      [:total, lunar_eclipse.total]
    ].select { |_name, phase| phase }
  end

  def lunar_eclipses_canonical_url(year)
    return lunar_eclipses_url if year == Time.current.year

    lunar_eclipses_url(year: year)
  end

  def lunar_eclipse_date(lunar_eclipse)
    lunar_eclipse.instant.to_time.utc.to_date
  end

  def lunar_eclipse_visibility(lunar_eclipse, observer)
    lunar_eclipse.visibility_from(observer)
  end

  def lunar_eclipse_horizon_events(lunar_eclipse, visibility)
    first_contact = lunar_eclipse.penumbral.starting_instant
    last_contact = lunar_eclipse.penumbral.ending_instant

    visibility.observable_windows.flat_map do |window|
      [
        ([:moonrise, window.first] unless window.first == first_contact),
        ([:moonset, window.last] unless window.last == last_contact)
      ].compact
    end.map { |name, instant| HorizonEvent.new(name, instant.to_time) }
  end
end
