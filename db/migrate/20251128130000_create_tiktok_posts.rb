# frozen_string_literal: true

class CreateTiktokPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :tiktok_posts do |t|
      t.text :data
      t.bigint :tiktok_profile_id, null: false
      t.string :tiktok_post_id
      t.text :desc
      t.datetime :posted_at
      
      # Stats
      t.integer :likes_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :play_count, default: 0
      t.integer :shares_count, default: 0
      t.integer :collects_count, default: 0
      t.integer :total_count, default: 0
      
      # Video info
      t.text :video_url
      t.text :cover_url
      t.text :dynamic_cover_url
      t.integer :video_duration
      t.string :video_definition
      
      # Music info
      t.string :music_title
      t.string :music_author
      t.text :music_play_url
      
      t.timestamps
    end

    add_index :tiktok_posts, :tiktok_profile_id
    add_index :tiktok_posts, :tiktok_post_id, unique: true
    add_index :tiktok_posts, :posted_at
    add_index :tiktok_posts, [:tiktok_profile_id, :posted_at]
    
    add_foreign_key :tiktok_posts, :tiktok_profiles
  end
end

