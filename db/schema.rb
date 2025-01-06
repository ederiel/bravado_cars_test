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

ActiveRecord::Schema.define(version: 2024_12_31_134300) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cars", force: :cascade do |t|
    t.string "model"
    t.bigint "brand_id", null: false
    t.integer "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_cars_on_brand_id"
    t.index ["price"], name: "index_cars_on_price"
  end

  create_table "user_car_external_recommendations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "car_id", null: false
    t.float "rank_score", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "retrieved_at", null: false
    t.index ["car_id"], name: "index_user_car_external_recommendations_on_car_id"
    t.index ["rank_score"], name: "index_user_car_external_recommendations_on_rank_score"
    t.index ["user_id"], name: "index_user_car_external_recommendations_on_user_id"
  end

  create_table "user_preferred_brands", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "brand_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_user_preferred_brands_on_brand_id"
    t.index ["user_id"], name: "index_user_preferred_brands_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.int8range "preferred_price_range"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "cars", "brands"
  add_foreign_key "user_car_external_recommendations", "cars"
  add_foreign_key "user_car_external_recommendations", "users"
  add_foreign_key "user_preferred_brands", "brands"
  add_foreign_key "user_preferred_brands", "users"
end
