# frozen_string_literal: true

class Constellation
  attr_reader :abbreviation, :name, :emoji

  def initialize(abbreviation)
    @abbreviation = abbreviation.downcase
    @name = I18n.t("constellation.human_name.#{@abbreviation}")
    @emoji = I18n.t("constellation.emoji.#{@abbreviation}")
  end

  def self.from_astronoby(astronoby_constellation)
    find_by_abbreviation(astronoby_constellation.abbreviation)
  end

  def self.find_by_abbreviation(abbreviation)
    new(abbreviation)
  end
end
