# frozen_string_literal: true

class CreateTiktokProfiles < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:tiktok_profiles)

    create_table :tiktok_profiles do |t|
      t.string :username
      t.text :data

      # Basic profile info
      t.string :unique_id
      t.string :nickname
      t.text :signature
      t.string :user_id
      t.string :sec_uid

      # Stats
      t.integer :followers, default: 0
      t.integer :following, default: 0
      t.integer :hearts, default: 0
      t.integer :video_count, default: 0
      t.integer :digg_count, default: 0
      t.integer :friend_count, default: 0

      # Status flags
      t.boolean :verified, default: false
      t.boolean :is_private, default: false
      t.boolean :is_under_age_18, default: false
      t.boolean :is_embed_banned, default: false
      t.boolean :commerce_user, default: false
      t.boolean :enabled, default: false, null: false

      # Avatar URLs
      t.text :avatar_larger
      t.text :avatar_medium
      t.text :avatar_thumb

      # Additional fields (similar to Profile model)
      t.string :country_string
      t.integer :profile_type
      t.text :query

      t.timestamps
    end

    add_index :tiktok_profiles, :username, unique: true unless index_exists?(:tiktok_profiles, :username)
    add_index :tiktok_profiles, :unique_id, unique: true unless index_exists?(:tiktok_profiles, :unique_id)
    add_index :tiktok_profiles, :enabled unless index_exists?(:tiktok_profiles, :enabled)
    add_index :tiktok_profiles, :country_string unless index_exists?(:tiktok_profiles, :country_string)
    add_index :tiktok_profiles, :followers unless index_exists?(:tiktok_profiles, :followers)
    
    # Add compound index if it doesn't exist
    unless index_exists?(:tiktok_profiles, [:enabled, :country_string, :followers], name: 'idx_tiktok_profiles_enabled_country_followers')
      add_index :tiktok_profiles, [:enabled, :country_string, :followers], name: 'idx_tiktok_profiles_enabled_country_followers'
    end
  end

  def down
    drop_table :tiktok_profiles if table_exists?(:tiktok_profiles)
  end
end

