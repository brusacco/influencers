# frozen_string_literal: true

namespace :instagram do
  desc 'Create daily profile stats'
  task create_daily_stats: :environment do
    yesterday = Date.yesterday
    start_of_day = yesterday.beginning_of_day
    end_of_day = yesterday.end_of_day

    Profile.tracked.each do |profile|
      posts = profile.instagram_posts.where(posted_at: start_of_day..end_of_day)
      next if posts.empty?

      total_likes = posts.sum(:likes_count)
      total_comments = posts.sum(:comments_count)
      total_video_views = posts.sum(:video_view_count)
      total_posts = posts.count

      InstagramProfileStat.find_or_create_by(profile:, date: yesterday) do |stat|
        stat.followers_count = profile.followers
        stat.total_likes = total_likes
        stat.total_comments = total_comments
        stat.total_video_views = total_video_views
        stat.total_posts = total_posts
      end

      puts "Created stats for #{profile.username} on #{yesterday}"
    end
  end
end
