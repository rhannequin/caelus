# frozen_string_literal: true

class Mercury
  include Planetable

  def self.planet_class
    Astronoby::Mercury
  end

  def self.key
    :mercury
  end

  def self.color
    "#cfc3aa"
  end

  def self.symbol
    "☿"
  end

  def initialize(observer:, time:)
    @observer = observer
    @time = time
  end
end
