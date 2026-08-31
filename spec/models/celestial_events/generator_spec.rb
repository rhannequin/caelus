require "rails_helper"

RSpec.describe CelestialEvents::Generator, type: :model do
  describe "#generate" do
    it "creates celestial events for the given event type" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)
      allow(CelestialEvents::OppositionsGenerator)
        .to receive(:new).and_call_original

      CelestialEvents::Generator
        .new(start_date, end_date)
        .generate(CelestialEvents::Generator::OPPOSITIONS)

      expect(CelestialEvents::OppositionsGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
    end

    it "raises an error for unsupported event types" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::Generator.new(start_date, end_date)

      expect { generator.generate(:unsupported_event_type) }
        .to raise_error(ArgumentError, /Unsupported event type/)
    end
  end

  describe "#generate_all" do
    it "creates celestial events for all supported event types" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)
      allow(CelestialEvents::OppositionsGenerator)
        .to receive(:new).and_call_original
      allow(CelestialEvents::LunarEclipsesGenerator)
        .to receive(:new).and_call_original
      allow(CelestialEvents::GreatestElongationsGenerator)
        .to receive(:new).and_call_original
      allow(CelestialEvents::MoonPhasesGenerator)
        .to receive(:new).and_call_original
      allow(CelestialEvents::EquinoxesSolsticesGenerator)
        .to receive(:new).and_call_original

      CelestialEvents::Generator
        .new(start_date, end_date)
        .generate_all

      expect(CelestialEvents::OppositionsGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
      expect(CelestialEvents::LunarEclipsesGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
      expect(CelestialEvents::GreatestElongationsGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
      expect(CelestialEvents::MoonPhasesGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
      expect(CelestialEvents::EquinoxesSolsticesGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
    end
  end
end
