class CreateCelestialEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :celestial_events do |t|
      t.string :kind
      t.decimal :peak_tt, null: false, precision: 15, scale: 6
      t.datetime :peak_at, null: false
      t.string :primary_body
      t.string :secondary_body

      t.timestamps
    end
  end
end
