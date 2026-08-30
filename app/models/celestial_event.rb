class CelestialEvent < ApplicationRecord
  KINDS = %w[opposition greatest_elongation].freeze

  validates :kind, presence: true, inclusion: {in: KINDS}
  validates :peak_tt, presence: true
  validates :peak_at, presence: true

  before_validation(
    :set_peak_at,
    if: -> { peak_tt.present? && peak_tt_changed? }
  )

  scope :between, ->(from, to) { where(peak_at: from..to) }
  scope :of_kind, ->(kinds) { where(kind: kinds) if kinds.present? }
  scope :chronological, -> { order(:peak_at) }

  def instant
    Astronoby::Instant.from_terrestrial_time(peak_tt)
  end

  private

  def set_peak_at
    self.peak_at = instant.to_time
  end
end
