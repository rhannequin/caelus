# frozen_string_literal: true

module CelestialBodies
  ALL = [
    Earth,
    Jupiter,
    Mars,
    Mercury,
    Moon,
    Neptune,
    Saturn,
    Sun,
    Uranus,
    Venus
  ].freeze

  module_function

  def find(name)
    return if name.blank?

    ALL.find { |body| body.key.to_s == name.to_s.downcase }
  end
end
