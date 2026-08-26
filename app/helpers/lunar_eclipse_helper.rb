# frozen_string_literal: true

module LunarEclipseHelper
  Contact = Struct.new(:key, :time, :position_angle)

  def lunar_eclipse_contacts(lunar_eclipse)
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
      Contact.new(key, instant.to_time, geometry.position_angle)
    end
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
