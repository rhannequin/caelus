# frozen_string_literal: true

class CelestialEvent < ApplicationRecord
  KINDS = [
    FIRST_QUARTER = "first_quarter",
    FULL_MOON = "full_moon",
    GREATEST_ELONGATION = "greatest_elongation",
    LAST_QUARTER = "last_quarter",
    LUNAR_ECLIPSE = "lunar_eclipse",
    NEW_MOON = "new_moon",
    OPPOSITION = "opposition"
  ].freeze

  KINDS_WITH_BODY = [GREATEST_ELONGATION, OPPOSITION].freeze

  MOON_PHASE_KINDS = [
    NEW_MOON,
    FIRST_QUARTER,
    FULL_MOON,
    LAST_QUARTER
  ].freeze

  validates :kind, presence: true, inclusion: {in: KINDS}
  validates :primary_body,
    presence: true,
    if: -> { KINDS_WITH_BODY.include?(kind) }
  validates :peak_tt, presence: true
  validates :peak_at, presence: true

  before_validation(
    :set_peak_at,
    if: -> { peak_tt.present? && peak_tt_changed? }
  )

  scope :between, ->(from, to) { where(peak_at: from..to) }
  scope :moon_phases, -> { where(kind: MOON_PHASE_KINDS) }
  scope :notable, -> { where.not(kind: MOON_PHASE_KINDS) }
  scope :of_kind, ->(kinds) { where(kind: kinds) }
  scope :chronological, -> { order(:peak_at) }

  def instant
    Astronoby::Instant.from_terrestrial_time(peak_tt)
  end

  private

  def set_peak_at
    self.peak_at = instant.to_time
  end
end
