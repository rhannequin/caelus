class RequireKindOnCelestialEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :celestial_events, :kind, false
  end
end
