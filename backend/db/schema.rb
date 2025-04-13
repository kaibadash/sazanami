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

ActiveRecord::Schema[8.0].define(version: 20_250_413_053_928) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "label", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "metric_values", force: :cascade do |t|
    t.bigint "metric_id", null: false
    t.decimal "value", precision: 15, scale: 2, null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_id"], name: "index_metric_values_on_metric_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.string "label", default: "", null: false
    t.string "unit", null: false
    t.boolean "prefix_unit", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "name"], name: "index_metrics_on_category_id_and_name", unique: true
    t.index ["category_id"], name: "index_metrics_on_category_id"
  end

  add_foreign_key "metric_values", "metrics"
  add_foreign_key "metrics", "categories"
end
