# frozen_string_literal: true

module CelestialEventHelper
  def celestial_event_title(event)
    I18n.t(
      "almanac.show.kinds.#{event.kind}.title",
      body: celestial_event_body_name(event)
    )
  end

  def celestial_event_kind_name(event)
    I18n.t("almanac.show.kinds.#{event.kind}.name")
  end

  def celestial_event_body_name(event)
    I18n.t("models.planets.#{event.primary_body.to_s.downcase}.name")
  end
end
