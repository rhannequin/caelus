# frozen_string_literal: true

class Venus
  include Planetable

  def self.planet_class
    Astronoby::Venus
  end

  def self.key
    :venus
  end

  def self.color
    "#fff8ec"
  end

  def self.symbol
    "♀"
  end

  def initialize(observer:, time:)
    @observer = observer
    @time = time
  end
end
