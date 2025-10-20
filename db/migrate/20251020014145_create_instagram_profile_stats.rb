# frozen_string_literal: true

class CreateInstagramProfileStats < ActiveRecord::Migration[7.0]
  def change
    create_table :instagram_profile_stats do |t|
      t.references :profile, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :followers_count, default: 0
      t.integer :total_likes, default: 0
      t.integer :total_comments, default: 0
      t.integer :total_video_views, default: 0
      t.integer :total_interactions_count, default: 0
      t.integer :total_posts, default: 0
      t.integer :total_videos, default: 0
      t.integer :engagement_rate, default: 0

      t.timestamps

      t.index %i[profile_id date], unique: true
    end
  end
end
