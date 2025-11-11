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

ActiveRecord::Schema[7.0].define(version: 2025_11_11_132004) do
  create_table "active_admin_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "instagram_collaborations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "instagram_post_id"
    t.integer "collaborator_id"
    t.integer "collaborated_id"
    t.datetime "posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborated_id", "posted_at"], name: "index_ig_collaborated_posted_at"
    t.index ["collaborated_id"], name: "index_instagram_collaborations_on_collaborated_id"
    t.index ["collaborator_id", "posted_at"], name: "index_ig_collab_posted_at"
    t.index ["collaborator_id"], name: "index_instagram_collaborations_on_collaborator_id"
    t.index ["instagram_post_id", "collaborator_id"], name: "index_ig_post_collab"
    t.index ["instagram_post_id"], name: "index_instagram_collaborations_on_instagram_post_id"
    t.index ["posted_at"], name: "index_instagram_collaborations_on_posted_at"
  end

  create_table "instagram_posts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "data"
    t.bigint "profile_id", null: false
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
    t.index ["posted_at"], name: "index_instagram_posts_on_posted_at"
    t.index ["product_type"], name: "index_instagram_posts_on_product_type"
    t.index ["profile_id", "posted_at"], name: "index_instagram_posts_on_profile_id_and_posted_at"
    t.index ["profile_id"], name: "index_instagram_posts_on_profile_id"
    t.index ["shortcode"], name: "index_instagram_posts_on_shortcode"
  end

  create_table "instagram_profile_stats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.date "date", null: false
    t.integer "followers_count", default: 0
    t.integer "total_likes", default: 0
    t.integer "total_comments", default: 0
    t.integer "total_video_views", default: 0
    t.integer "total_interactions_count", default: 0
    t.integer "total_posts", default: 0
    t.integer "total_videos", default: 0
    t.integer "engagement_rate", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "date"], name: "index_instagram_profile_stats_on_profile_id_and_date", unique: true
    t.index ["profile_id"], name: "index_instagram_profile_stats_on_profile_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "followers", default: 0
    t.integer "following", default: 0
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
    t.integer "total_likes_count", default: 0
    t.integer "total_comments_count", default: 0
    t.integer "total_video_view_count", default: 0
    t.integer "total_interactions_count", default: 0
    t.integer "total_posts", default: 0
    t.integer "total_videos", default: 0
    t.integer "engagement_rate", default: 0
    t.integer "profile_type"
    t.text "query"
    t.string "uid"
    t.boolean "enabled", default: false, null: false
    t.index ["country_string", "followers"], name: "index_profiles_on_country_and_followers", comment: "Optimizes queries filtering by country and followers range"
    t.index ["country_string"], name: "index_instagram_profiles_on_country_string"
    t.index ["enabled", "country_string", "followers"], name: "index_profiles_on_enabled_country_followers", comment: "Optimizes queries for enabled profiles by country ordered by followers"
    t.index ["enabled", "country_string", "profile_type", "followers"], name: "index_profiles_on_enabled_country_type_followers", comment: "Optimizes queries for enabled profiles by country, type, and followers ordering"
    t.index ["enabled", "country_string", "profile_type"], name: "index_profiles_on_enabled_country_type", comment: "Optimizes queries for enabled profiles by country and type"
    t.index ["enabled", "country_string"], name: "index_profiles_on_enabled_and_country", comment: "Optimizes queries for enabled profiles by country"
    t.index ["enabled"], name: "index_profiles_on_enabled"
    t.index ["profile_type"], name: "index_profiles_on_profile_type"
    t.index ["username"], name: "index_instagram_profiles_on_username", unique: true
  end

  create_table "taggings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "instagram_posts", "profiles"
  add_foreign_key "instagram_profile_stats", "profiles"
  add_foreign_key "taggings", "tags"
end
