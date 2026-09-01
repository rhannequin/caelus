# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_01_090000) do
  create_table "celestial_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.datetime "peak_at", null: false
    t.decimal "peak_tt", precision: 15, scale: 6, null: false
    t.string "primary_body"
    t.string "secondary_body"
    t.datetime "updated_at", null: false
    t.index ["kind", "peak_at"], name: "index_celestial_events_on_kind_and_peak_at"
    t.index ["peak_at"], name: "index_celestial_events_on_peak_at"
  end
end
