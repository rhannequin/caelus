# frozen_string_literal: true

module Lunar
  ProjectedFeature = Data.define(:name, :kind, :points) do
    def renderable?
      points.size >= 3
    end
  end
end
