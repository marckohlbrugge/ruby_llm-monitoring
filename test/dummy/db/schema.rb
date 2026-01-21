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

ActiveRecord::Schema[8.1].define(version: 2026_01_21_111526) do
  create_table "ruby_llm_monitoring_events", force: :cascade do |t|
    t.integer "allocations"
    t.float "cost"
    t.float "cpu_time"
    t.datetime "created_at", null: false
    t.float "duration"
    t.float "end"
    t.float "gc_time"
    t.float "idle_time"
    t.string "name"
    t.json "payload"
    t.float "time"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_ruby_llm_monitoring_events_on_created_at"
  end
end
