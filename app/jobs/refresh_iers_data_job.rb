# frozen_string_literal: true

class RefreshIersDataJob < ApplicationJob
  class RefreshError < StandardError; end

  retry_on RefreshError, wait: :polynomially_longer, attempts: 3

  def perform
    result = IERS::Data.update!

    unless result.success?
      details = result.errors
        .map { |source, error| "#{source}: #{error.message}" }
        .join("; ")
      raise RefreshError, "IERS data refresh failed (#{details})"
    end

    IERS::Data.clear_loaded!
  end
end
