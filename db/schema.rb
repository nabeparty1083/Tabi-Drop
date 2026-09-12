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

ActiveRecord::Schema[8.1].define(version: 2026_09_12_032800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "reviews", force: :cascade do |t|
    t.text "bad_point"
    t.text "body", null: false
    t.integer "companion_type", null: false
    t.datetime "created_at", null: false
    t.text "good_point"
    t.string "image"
    t.integer "purpose", null: false
    t.integer "rating", null: false
    t.integer "season", null: false
    t.bigint "spot_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["spot_id"], name: "index_reviews_on_spot_id"
    t.index ["user_id", "spot_id"], name: "index_reviews_on_user_id_and_spot_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "spots", force: :cascade do |t|
    t.string "address", null: false
    t.integer "category", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "official_url"
    t.string "prefecture", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "address"], name: "index_spots_on_name_and_address", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "reviews", "spots"
  add_foreign_key "reviews", "users"
end
