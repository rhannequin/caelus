require "rails_helper"

RSpec.describe CelestialEvent, type: :model do
  describe "factory" do
    it "is valid" do
      expect(build(:celestial_event)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it do
      is_expected.to validate_inclusion_of(:kind)
        .in_array(CelestialEvent::KINDS)
    end
    it { is_expected.to validate_presence_of(:peak_tt) }
    it { is_expected.to validate_presence_of(:peak_at) }

    describe "#primary_body" do
      it "is required for a kind that names a body" do
        event = build(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: nil
        )

        expect(event).not_to be_valid
        expect(event.errors[:primary_body]).to include("can't be blank")
      end

      it "is optional for a kind that names no body" do
        event = build(
          :celestial_event,
          kind: CelestialEvent::LUNAR_ECLIPSE,
          primary_body: nil
        )

        expect(event).to be_valid
      end
    end
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

  describe "#to_param" do
    it "names the date and both planets of a planetary conjunction" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      expect(event.to_param).to eq("2026-11-16-mars-jupiter")
    end

    it "puts the Moon first when it meets a planet" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 6, 36)
      )

      expect(event.to_param).to eq("2026-09-27-moon-saturn")
    end

    it "uses the UTC date rather than the local one" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
        primary_body: "Saturn",
        peak: Time.utc(2026, 9, 27, 23, 30)
      )

      Time.use_zone("Asia/Tokyo") do
        expect(event.to_param).to eq("2026-09-27-moon-saturn")
      end
    end

    it "names only the date for a kind without bodies" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::LUNAR_ECLIPSE,
        peak: Time.utc(2026, 8, 28, 4, 12)
      )

      expect(event.to_param).to eq("2026-08-28")
    end
  end

  describe ".from_param" do
    it "finds the event a slug was built from" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      found = described_class.from_param(
        event.to_param,
        kinds: [CelestialEvent::PLANETARY_CONJUNCTION]
      )

      expect(found).to eq(event)
    end

    it "ignores an event of another kind on the same day" do
      event = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )

      found = described_class.from_param(
        event.to_param,
        kinds: [CelestialEvent::MOON_PLANET_CONJUNCTION]
      )

      expect(found).to be_nil
    end

    it "tells apart two conjunctions sharing a day" do
      create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Mars",
        secondary_body: "Jupiter",
        peak: Time.utc(2026, 11, 16, 2, 4)
      )
      venus = create(
        :celestial_event,
        kind: CelestialEvent::PLANETARY_CONJUNCTION,
        primary_body: "Venus",
        secondary_body: "Saturn",
        peak: Time.utc(2026, 11, 16, 20, 15)
      )

      found = described_class.from_param(
        "2026-11-16-venus-saturn",
        kinds: [CelestialEvent::PLANETARY_CONJUNCTION]
      )

      expect(found).to eq(venus)
    end

    it "returns nil when the slug does not start with a date" do
      found = described_class.from_param(
        "mars-jupiter",
        kinds: [CelestialEvent::PLANETARY_CONJUNCTION]
      )

      expect(found).to be_nil
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
        event1 = create(
          :celestial_event,
          kind: "opposition",
          primary_body: "Mars"
        )
        _event2 = create(
          :celestial_event,
          kind: "greatest_elongation",
          primary_body: "Venus"
        )
        event3 = create(
          :celestial_event,
          kind: "opposition",
          primary_body: "Jupiter"
        )

        oppositions = CelestialEvent.of_kind("opposition")

        expect(oppositions).to contain_exactly(event1, event3)
      end
    end

    describe ".moon_phases" do
      it "returns only the principal moon phases" do
        full_moon = create(:celestial_event, kind: CelestialEvent::FULL_MOON)
        _opposition = create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars"
        )

        expect(CelestialEvent.moon_phases).to contain_exactly(full_moon)
      end
    end

    describe ".moon_apsides" do
      it "returns only the lunar apsides" do
        perigee = create(:celestial_event, kind: CelestialEvent::MOON_PERIGEE)
        _opposition = create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars"
        )

        expect(CelestialEvent.moon_apsides).to contain_exactly(perigee)
      end
    end

    describe ".notable" do
      it "returns everything that is not part of the lunar rhythm" do
        _full_moon = create(:celestial_event, kind: CelestialEvent::FULL_MOON)
        _perigee = create(:celestial_event, kind: CelestialEvent::MOON_PERIGEE)
        _apogee = create(:celestial_event, kind: CelestialEvent::MOON_APOGEE)
        opposition = create(
          :celestial_event,
          kind: CelestialEvent::OPPOSITION,
          primary_body: "Mars"
        )
        eclipse = create(:celestial_event, kind: CelestialEvent::LUNAR_ECLIPSE)

        expect(CelestialEvent.notable)
          .to contain_exactly(opposition, eclipse)
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
