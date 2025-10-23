# frozen_string_literal: true

class Neptune
  include Planetable

  def self.planet_class
    Astronoby::Neptune
  end

  def self.key
    :neptune
  end

  def self.symbol
    "♆"
  end

  def initialize(observer:, time: Time.current)
    @observer = observer
    @time = time
  end
end
