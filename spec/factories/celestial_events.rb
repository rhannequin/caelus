FactoryBot.define do
  factory :celestial_event do
    transient do
      peak { Time.utc(2026, 8, 28, 4, 12) }
    end

    kind { CelestialEvent::LUNAR_ECLIPSE }
    peak_tt { Astronoby::Instant.from_time(peak).tt }
  end
end
