# frozen_string_literal: true

class Saturn
  include Planetable

  def self.planet_class
    Astronoby::Saturn
  end

  def self.key
    :saturn
  end

  def self.symbol
    "♄"
  end

  def initialize(observer:, time: Time.now)
    @observer = observer
    @time = time
  end
end
