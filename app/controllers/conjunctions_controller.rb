# frozen_string_literal: true

class ConjunctionsController < ApplicationController
  def show
    @conjunction = Conjunction.new(
      celestial_event: celestial_event,
      observer: @observer
    )

    raise Caelus::NotFound unless @conjunction.known_bodies?

    track_page_view("conjunction")
  end

  private

  def celestial_event
    CelestialEvent
      .of_kind(Conjunction::KINDS)
      .find_by(id: params[:id]) || raise(Caelus::NotFound)
  end
end
