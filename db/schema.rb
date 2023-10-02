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

ActiveRecord::Schema[7.0].define(version: 2023_10_01_214355) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "instagram_posts", force: :cascade do |t|
    t.text "data"
    t.integer "profile_id", null: false
    t.text "image"
    t.string "shortcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0
    t.integer "comments_count", default: 0
    t.integer "video_view_count", default: 0
    t.string "product_type"
    t.string "media"
    t.text "caption"
    t.string "url"
    t.datetime "posted_at"
    t.integer "total_count", default: 0
    t.index ["media"], name: "index_instagram_posts_on_media"
    t.index ["product_type"], name: "index_instagram_posts_on_product_type"
    t.index ["profile_id"], name: "index_instagram_posts_on_profile_id"
    t.index ["shortcode"], name: "index_instagram_posts_on_shortcode"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "username"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "followers", default: 0
    t.integer "following", default: 0
    t.text "avatar"
    t.text "profile_pic_url"
    t.boolean "is_business_account", default: false
    t.boolean "is_professional_account", default: false
    t.string "business_category_name"
    t.string "category_enum"
    t.string "category_name"
    t.boolean "is_private", default: false
    t.boolean "is_verified", default: false
    t.string "full_name"
    t.text "biography"
    t.boolean "is_joined_recently", default: false
    t.boolean "is_embeds_disabled", default: false
    t.string "country_string"
    t.text "profile_pic_url_hd"
    t.index ["country_string"], name: "index_profiles_on_country_string"
    t.index ["username"], name: "index_profiles_on_username", unique: true
  end

  add_foreign_key "instagram_posts", "profiles"
end
