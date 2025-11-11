# frozen_string_literal: true

require "singleton"

Astronoby.configuration.cache_enabled = true

class SPK
  include Singleton

  def self.inpop19a
    instance.inpop19a
  end

  def inpop19a
    @inpop19a ||= Astronoby::Ephem.load("lib/astronoby/spk/inpop19a.bsp")
  end

  def self.for_time(time)
    instance.for_time(time)
  end

  def for_time(time)
    year = time.utc.year
    var_name = "@inpop19a_#{year}"

    instance_variable_get(var_name) || instance_variable_set(
      var_name,
      (
        previous_year = year - 1
        next_year = year + 1
        file_path = "lib/astronoby/spk/inpop19a_#{previous_year}_#{next_year}.bsp"
        if File.exist?(file_path)
          Astronoby::Ephem.load(file_path)
        else
          inpop19a
        end
      )
    )
  end
end
