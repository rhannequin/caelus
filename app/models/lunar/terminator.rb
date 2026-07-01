# frozen_string_literal: true

module Lunar
  Terminator = Data.define(:phase_angle, :bright_limb_angle) do
    def axis_ratio
      phase_angle.cos.abs
    end
  end
end
