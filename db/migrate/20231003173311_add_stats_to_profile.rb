class AddStatsToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :total_likes_count, :integer, default: 0
    add_column :profiles, :total_comments_count, :integer, default: 0
    add_column :profiles, :total_video_view_count, :integer, default: 0
    add_column :profiles, :total_interactions_count, :integer, default: 0
    add_column :profiles, :total_posts, :integer, default: 0
    add_column :profiles, :total_videos, :integer, default: 0
    add_column :profiles, :engagement_rate, :integer, default: 0
  end
end
