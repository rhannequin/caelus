require "rails_helper"

RSpec.describe CelestialEvents::Generator, type: :model do
  describe "#generate" do
    it "creates celestial events for the given event type" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)
      allow(CelestialEvents::OppositionsGenerator)
        .to receive(:new).and_call_original

      CelestialEvents::Generator.new(
        CelestialEvents::Generator::OPPOSITIONS,
        start_date,
        end_date
      ).generate

      expect(CelestialEvents::OppositionsGenerator)
        .to have_received(:new)
        .with(start_date, end_date)
    end

    it "raises an error for unsupported event types" do
      start_date = Time.utc(2026, 1, 1)
      end_date = Time.utc(2027, 1, 1)

      generator = CelestialEvents::Generator.new(
        :unsupported_event_type,
        start_date,
        end_date
      )

      expect { generator.generate }
        .to raise_error(ArgumentError, /Unsupported event type/)
    end
  end
end
