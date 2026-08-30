# frozen_string_literal: true

require "singleton"

Astronoby.configuration.cache_enabled = true

IERS.configure do |config|
  config.cache_dir = Rails.root.join("storage/iers")
end

# Parse the IERS finals data at boot so the first request doesn't pay the
# one-time lazy-parse cost.
Rails.application.config.after_initialize { IERS::Data.finals_entries }

class SPK
  include Singleton

  def inpop19a
    @inpop19a ||= Astronoby::Ephem.load("lib/astronoby/spk/inpop19a.bsp")
  end

  def self.inpop19a
    instance.inpop19a
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
          Rails.logger.warn(
            "SPK file #{file_path} not found, falling back to full inpop19a SPK"
          )
          inpop19a
        end
      )
    )
  end
end
