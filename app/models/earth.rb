# frozen_string_literal: true

class Earth
  include Planetable

  def self.planet_class
    Astronoby::Earth
  end

  def self.key
    :earth
  end

  def self.symbol
    "⊕"
  end

  def initialize(observer:, time: Time.now)
    @observer = observer
    @time = time
  end

  def distance_from_earth
    Astronoby::Distance.zero
  end
end
