# frozen_string_literal: true

module CelestialEventHelper
  def celestial_event_title(event)
    I18n.t(
      "almanac.show.kinds.#{event.kind}.title",
      body: celestial_event_body_name(event),
      secondary_body: celestial_event_secondary_body_name(event),
      date: I18n.l(event.peak_at.in_time_zone.to_date, format: :long)
    )
  end

  def celestial_event_kind_name(event)
    I18n.t("almanac.show.kinds.#{event.kind}.name")
  end

  def celestial_event_body_name(event)
    planet_name(event.primary_body)
  end

  def celestial_event_secondary_body_name(event)
    planet_name(event.secondary_body)
  end

  def planet_name(body)
    return if body.blank?

    I18n.t("models.planets.#{body.downcase}.name")
  end
end
