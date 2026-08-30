require "rails_helper"

RSpec.describe CelestialEvent, type: :model do
  describe "factory" do
    it "is valid" do
      expect(build(:celestial_event)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:peak_tt) }
    it { is_expected.to validate_presence_of(:peak_at) }
  end

  describe "#peak_at" do
    it "is set from peak_tt" do
      event = build(:celestial_event, peak_tt: 2437870.0003965567)
      expect(event.peak_at).to be_nil

      event.valid?

      expect(event.peak_at.round).to eq(Time.utc(1962, 7, 24, 12))
    end
  end

  describe "#instant" do
    it "returns an Astronoby::Instant" do
      event = build(:celestial_event, peak_tt: 2437870.0003965567)

      expect(event.instant).to be_a(Astronoby::Instant)
      expect(event.instant.tt).to eq(0.2437870000397e7)
    end
  end

  describe "scopes" do
    describe ".between" do
      it "returns events between two dates" do
        event1 = create(:celestial_event, peak: Time.utc(2024, 1, 1))
        event2 = create(:celestial_event, peak: Time.utc(2024, 6, 1))
        _event3 = create(:celestial_event, peak: Time.utc(2024, 12, 31))

        between = CelestialEvent.between(
          Time.utc(2024, 1, 1),
          Time.utc(2024, 6, 30)
        )

        expect(between).to contain_exactly(event1, event2)
      end
    end

    describe ".of_kind" do
      it "returns events of the given kind" do
        event1 = create(:celestial_event, kind: "eclipse")
        _event2 = create(:celestial_event, kind: "transit")
        event3 = create(:celestial_event, kind: "eclipse")

        eclipses = CelestialEvent.of_kind("eclipse")

        expect(eclipses).to contain_exactly(event1, event3)
      end
    end

    describe ".chronological" do
      it "returns events in chronological order" do
        event1 = create(:celestial_event, peak: Time.utc(2024, 6, 1))
        event2 = create(:celestial_event, peak: Time.utc(2024, 1, 1))
        event3 = create(:celestial_event, peak: Time.utc(2024, 12, 31))

        chronological = CelestialEvent.chronological

        expect(chronological).to eq([event2, event1, event3])
      end
    end
  end
end
