# frozen_string_literal: true

module LunarEclipseHelper
  def lunar_eclipse_contacts(lunar_eclipse)
    umbral = lunar_eclipse.partial
    totality = lunar_eclipse.total

    [
      [:p1, lunar_eclipse.penumbral.starting_instant],
      ([:u1, umbral.starting_instant] if umbral),
      ([:u2, totality.starting_instant] if totality),
      [:greatest, lunar_eclipse.instant],
      ([:u3, totality.ending_instant] if totality),
      ([:u4, umbral.ending_instant] if umbral),
      [:p4, lunar_eclipse.penumbral.ending_instant]
    ].compact.map { |key, instant| [key, instant.to_time] }
  end

  def lunar_eclipse_phases(lunar_eclipse)
    [
      [:penumbral, lunar_eclipse.penumbral],
      [:partial, lunar_eclipse.partial],
      [:total, lunar_eclipse.total]
    ].select { |_name, phase| phase }
  end

  def lunar_eclipse_date(lunar_eclipse)
    lunar_eclipse.instant.to_time.utc.to_date
  end
end
