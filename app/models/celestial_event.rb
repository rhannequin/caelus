# frozen_string_literal: true

class CelestialEvent < ApplicationRecord
  KINDS = [
    DECEMBER_SOLSTICE = "december_solstice",
    FIRST_QUARTER = "first_quarter",
    FULL_MOON = "full_moon",
    GREATEST_ELONGATION = "greatest_elongation",
    JUNE_SOLSTICE = "june_solstice",
    LAST_QUARTER = "last_quarter",
    LUNAR_ECLIPSE = "lunar_eclipse",
    MARCH_EQUINOX = "march_equinox",
    MOON_PLANET_CONJUNCTION = "moon_planet_conjunction",
    NEW_MOON = "new_moon",
    OPPOSITION = "opposition",
    PLANETARY_CONJUNCTION = "planetary_conjunction",
    SEPTEMBER_EQUINOX = "september_equinox"
  ].freeze

  KINDS_WITH_BODY = [
    GREATEST_ELONGATION,
    MOON_PLANET_CONJUNCTION,
    OPPOSITION,
    PLANETARY_CONJUNCTION
  ].freeze

  KINDS_WITH_SECONDARY_BODY = [PLANETARY_CONJUNCTION].freeze

  SEASON_KINDS = [
    MARCH_EQUINOX,
    JUNE_SOLSTICE,
    SEPTEMBER_EQUINOX,
    DECEMBER_SOLSTICE
  ].freeze

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
  validates :secondary_body,
    presence: true,
    if: -> { KINDS_WITH_SECONDARY_BODY.include?(kind) }
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
