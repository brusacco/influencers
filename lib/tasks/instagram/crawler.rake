# frozen_string_literal: true

namespace :instagram do
  desc 'Main crawler'
  task crawler: :environment do
    Parallel.each(Profile.order(followers: :desc), in_threads: 5) do |profile|
      puts profile.username
      puts '----------------------------------'
      response = InstagramServices::GetProfileData.call(profile.username)
      next unless response.success?

      profile.update!(response.data)

      data = JSON.parse(profile.data)

      # Videos
      if data['graphql']['user']['edge_felix_video_timeline']
        videos = data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      videos.each do |video|
        next if video.nil? || video['node'].nil?

        puts video['node']['shortcode']
        db_post = profile.instagram_posts.find_or_create_by!(shortcode: video['node']['shortcode'])
        response = InstagramServices::UpdatePostData.call(video)
        db_post.update!(response.data) if response.success?
        db_post.save_image(video['node']['display_url']) if db_post.image.nil? || db_post.image.length < 1000
      end

      # Posts
      if data['graphql']['user']['edge_owner_to_timeline_media']
        posts = data['graphql']['user']['edge_owner_to_timeline_media']['edges']
      end

      posts.each do |_post|
        next if posts.nil? || posts['node'].nil?

        puts posts['node']['shortcode']
        db_post = profile.instagram_posts.find_or_create_by!(shortcode: posts['node']['shortcode'])
        response = InstagramServices::UpdatePostData.call(posts)
        db_post.update!(response.data) if response.success?
        db_post.save_image(posts['node']['display_url']) if db_post.image.nil? || db_post.image.length < 1000
      end
    rescue StandardError => e
      puts e.message
      retry
    end
  end
end
