# frozen_string_literal: true

module CelestialEvents
  module CloseApproaches
    MAX_APPROACH_SEPARATION = Astronoby::Angle.from_degrees(15)
    SAMPLE_STEP = 1.day
    REFINEMENT_WINDOW = 1.day
    REFINEMENT_ITERATIONS = 30

    Approach = Struct.new(
      :primary,
      :secondary,
      :time,
      :separation,
      :solar_elongation
    )

    private

    def close_approaches(primary, secondary)
      separation_samples(primary, secondary)
        .each_cons(3)
        .filter_map do |before, here, after|
          here.first if before.last > here.last && here.last <= after.last
        end
        .map { |time| approach_at(primary, secondary, time) }
        .select { |approach| near_pass?(approach) && covered?(approach.time) }
    end

    def near_pass?(approach)
      approach.separation <= MAX_APPROACH_SEPARATION
    end

    def covered?(time)
      time.between?(@start_date, @end_date)
    end

    def separation_samples(primary, secondary)
      sample_times.map { |time| [time, separation(primary, secondary, time)] }
    end

    def sample_times
      steps = ((@end_date - @start_date) / SAMPLE_STEP).ceil + 2
      first_sample = @start_date - SAMPLE_STEP
      (0..steps).map { |step| first_sample + (step * SAMPLE_STEP) }
    end

    def approach_at(primary, secondary, sampled_time)
      time = closest_approach(primary, secondary, sampled_time)

      Approach.new(
        primary,
        secondary,
        time,
        separation(primary, secondary, time),
        solar_elongation(primary, secondary, time)
      )
    end

    def closest_approach(primary, secondary, time)
      low = time - REFINEMENT_WINDOW
      high = time + REFINEMENT_WINDOW

      REFINEMENT_ITERATIONS.times do
        first = low + ((high - low) / 3)
        second = high - ((high - low) / 3)

        if separation(primary, secondary, first) <
            separation(primary, secondary, second)
          high = second
        else
          low = first
        end
      end

      low + ((high - low) / 2)
    end

    def separation(primary, secondary, time)
      apparent(primary, time).separation_from(apparent(secondary, time))
    end

    def solar_elongation(primary, secondary, time)
      [elongation(primary, time), elongation(secondary, time)].min
    end

    def elongation(body, time)
      apparent(body, time).separation_from(apparent(Astronoby::Sun, time))
    end

    def apparent(body, time)
      body_at(body, time).apparent
    end

    def magnitude(body, time)
      body_at(body, time).apparent_magnitude
    end

    def body_at(body, time)
      body.new(
        instant: Astronoby::Instant.from_time(time),
        ephem: SPK.inpop19a
      )
    end
  end
end
