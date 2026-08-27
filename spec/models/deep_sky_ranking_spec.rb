# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeepSkyRanking, type: :model do
  describe "#best" do
    it "recommends different objects in winter than in summer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      winter = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 1, 15)
        )
      ).best(6).map { |placement| placement.messier_object.number }

      summer = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 7, 15)
        )
      ).best(6).map { |placement| placement.messier_object.number }

      expect(winter).not_to match_array(summer)
    end

    it "returns nothing when the night offers no darkness" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(69.65),
        longitude: Astronoby::Angle.from_degrees(18.96)
      )

      ranking = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 6, 21)
        )
      )

      expect(ranking.best(10)).to be_empty
    end

    it "still recommends objects on a summer night without full darkness" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      night = ObservingNight.new(
        observer: observer,
        date: Date.new(2026, 6, 21)
      )

      expect(night).not_to be_full_darkness
      expect(described_class.new(night: night).best(10).size).to eq(10)
    end

    it "leaves out objects that never climb clear of the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      ranking = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 1, 15)
        )
      )

      numbers = ranking.placements.map do |placement|
        placement.messier_object.number
      end

      expect(numbers).not_to include(7)
      expect(ranking.placements).to all(
        have_attributes(
          highest_altitude: be >= described_class::MINIMUM_ALTITUDE
        )
      )
    end

    it "orders placements from best to worst" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      scores = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 1, 15)
        )
      ).placements.map(&:score)

      expect(scores).to eq(scores.sort.reverse)
    end
  end

  describe "variety" do
    it "does not fill the list with objects of one family" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      best = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 3, 15)
        )
      ).best(6)

      families = best.map do |placement|
        described_class::FAMILIES.fetch(placement.messier_object.type, :other)
      end

      expect(families.tally.values.max)
        .to be <= described_class::MAXIMUM_PER_FAMILY
    end

    it "still returns the requested number of objects" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )

      best = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 3, 15)
        )
      ).best(6)

      expect(best.size).to eq(6)
      expect(best.map { |placement| placement.messier_object.number }.uniq.size)
        .to eq(6)
    end
  end

  describe "moonlight" do
    it "demotes a galaxy below a cluster of similar standing under a bright Moon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      galaxy = MessierCatalog.find_by_number(31)
      cluster = MessierCatalog.find_by_number(45)

      full_moon = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 8, 27)
        ),
        messier_objects: [galaxy, cluster]
      ).placements

      new_moon = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 9, 10)
        ),
        messier_objects: [galaxy, cluster]
      ).placements

      expect(full_moon.first.messier_object).to eq(cluster)
      expect(new_moon.first.messier_object).to eq(galaxy)
    end
  end

  describe "notability" do
    it "prefers a showpiece over an ordinary object at the same altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8),
        longitude: Astronoby::Angle.from_degrees(2.3)
      )
      showpiece = MessierCatalog.find_by_number(81)
      ordinary = MessierCatalog.find_by_number(40)

      placements = described_class.new(
        night: ObservingNight.new(
          observer: observer,
          date: Date.new(2026, 3, 15)
        ),
        messier_objects: [ordinary, showpiece]
      ).placements

      expect(placements.first.messier_object).to eq(showpiece)
    end
  end
end
