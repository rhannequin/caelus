class AddIndexesToCelestialEvents < ActiveRecord::Migration[8.1]
  def change
    add_index :celestial_events, :peak_at
    add_index :celestial_events, [:kind, :peak_at]
  end
end
