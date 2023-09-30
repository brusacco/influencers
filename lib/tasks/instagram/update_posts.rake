# frozen_string_literal: true

namespace :instagram do
  desc 'Update/Create Instagram posts'
  task update_posts: :environment do
    profiles = Profile.order(followers: :desc)
    profiles.each do |profile|
      data = JSON.parse(profile.data)
      next if data.nil? || data['graphql'].nil? || data['graphql']['user'].nil?

      if data['graphql']['user']['edge_felix_video_timeline']
        videos = data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      videos.each do |video|
        next if video.nil? || video['node'].nil?

        puts video['node']['shortcode']
        post = profile.instagram_posts.find_or_create_by!(shortcode: video['node']['shortcode'])
        response = InstagramServices::UpdatePostData.call(video)
        post.update!(response.data) if response.success?
        post.save_image(video['node']['display_url'])
      end
    end
  end
end
