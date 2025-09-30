# frozen_string_literal: true

require "rails_helper"

RSpec.describe DistanceBarComponent, type: :component do
  it "renders successfully" do
    component = render_inline(
      described_class.new(
        start_distance: 0,
        current_distance: 25,
        end_distance: 100,
        start_distance_title: "Start",
        end_distance_title: "End"
      )
    ).to_html

    expect(component).to include("0&nbsp;km")
    expect(component).to include("100&nbsp;km")
    expect(component).to include("Start")
    expect(component).to include("End")
  end
end
