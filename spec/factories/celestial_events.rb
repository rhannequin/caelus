FactoryBot.define do
  factory :celestial_event do
    transient do
      peak { Time.utc(2023, 2, 24, 12) }
    end

    kind { "eclipse" }
    peak_tt { Astronoby::Instant.from_time(peak).tt }
  end
end
