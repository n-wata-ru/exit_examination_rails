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

ActiveRecord::Schema[8.1].define(version: 2025_12_08_090456) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "coffee_beans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "image"
    t.string "name"
    t.text "notes"
    t.bigint "origin_id", null: false
    t.string "process"
    t.string "roast_level"
    t.datetime "updated_at", null: false
    t.string "variety"
    t.index ["origin_id"], name: "index_coffee_beans_on_origin_id"
  end

  create_table "origins", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "farm_name"
    t.text "notes"
    t.string "region"
    t.datetime "updated_at", null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.text "notes"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "tasting_notes", force: :cascade do |t|
    t.integer "acidity_score"
    t.integer "bitterness_score"
    t.string "brew_method"
    t.bigint "coffee_bean_id", null: false
    t.datetime "created_at", null: false
    t.integer "preference_score"
    t.bigint "shop_id"
    t.integer "sweetness_score"
    t.text "taste_notes"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["coffee_bean_id"], name: "index_tasting_notes_on_coffee_bean_id"
    t.index ["shop_id"], name: "index_tasting_notes_on_shop_id"
    t.index ["user_id"], name: "index_tasting_notes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "coffee_beans", "origins"
  add_foreign_key "tasting_notes", "coffee_beans"
  add_foreign_key "tasting_notes", "shops"
  add_foreign_key "tasting_notes", "users"
end
