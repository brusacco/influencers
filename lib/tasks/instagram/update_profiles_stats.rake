# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles stats'
  task update_profiles_stats: :environment do
    Profile.all.order(followers: :desc).each do |profile|
      puts "Updating stats for #{profile.username}"
      stats_posts = profile.instagram_posts.a_week_ago

      profile.total_likes_count = stats_posts.sum(:likes_count)
      profile.total_comments_count = stats_posts.sum(:comments_count)
      profile.total_video_view_count = stats_posts.sum(:video_view_count)
      profile.total_interactions_count = stats_posts.sum(:total_count)
      profile.total_posts = stats_posts.count
      profile.total_videos = stats_posts.where(media: 'GraphVideo').count
      profile.engagement_rate = (stats_posts.sum(:total_count) / Float(profile.followers) * 100).round
      profile.save!
    rescue StandardError => e
      puts e.message
      next
    end
  end
end
