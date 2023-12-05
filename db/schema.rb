# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_06_212423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "operations", force: :cascade do |t|
    t.integer "operation_id"
    t.string "operation_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_data", force: :cascade do |t|
    t.bigint "product_id"
    t.string "load_data"
    t.string "unload_data"
    t.string "finish_data"
    t.string "fault_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cook_data"
    t.string "cool_data"
    t.index ["product_id"], name: "index_product_data_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "run_id"
    t.integer "work_order_id"
    t.string "grading"
    t.boolean "finish_flag"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["run_id"], name: "index_products_on_run_id"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "runs", force: :cascade do |t|
    t.integer "run_number"
    t.integer "arm_id"
    t.date "start_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arm_id"], name: "index_runs_on_arm_id"
    t.index ["run_number"], name: "index_runs_on_run_number"
  end

  create_table "timers", force: :cascade do |t|
    t.integer "entity_id"
    t.string "entity_type"
    t.string "status"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_sessions", force: :cascade do |t|
    t.string "user_name"
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_name"], name: "index_user_sessions_on_user_name"
  end

  add_foreign_key "product_data", "products"
  add_foreign_key "products", "runs"
  add_foreign_key "products", "user_sessions", column: "user_id"
end
