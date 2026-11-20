# frozen_string_literal: true

require "singleton"

class SkyCatalogs
  include Singleton

  class << self
    delegate :stars,
      :constellation_lines,
      :main_constellation_lines,
      to: :instance

    def preload
      instance.stars.search(magnitude_limit: SkyMap::STAR_MAGNITUDE_LIMIT)
    end
  end

  attr_reader :stars, :constellation_lines, :main_constellation_lines

  def initialize
    @stars = Skymap::Catalog::Stars.new
    @constellation_lines = Skymap::Catalog::ConstellationLines.new.to_a
    @main_constellation_lines = constellation_lines
      .reject { |line| line.weight == :thin }
  end
end
