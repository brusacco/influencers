# frozen_string_literal: true

namespace :instagram do
  desc 'Main crawler'
  task test: :environment do
    # Parallel.each(Profile.where(avatar: nil), in_threads: 5) do |profile|
    # Parallel.each(Profile.order(followers: :desc), in_threads: 5) do |profile|
    Profile.order(followers: :desc).each do |profile|
      puts profile.username
      puts '----------------------------------'

      response = InstagramServices::GetProfileData.call(profile.username)
      next unless response.success?

      profile.update!(response.data)
      data = JSON.parse(profile.data)

      postings = []

      #----------------------------------------------------------------
      # Videos
      #----------------------------------------------------------------
      if data['graphql']['user']['edge_felix_video_timeline']
        postings << data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      #----------------------------------------------------------------
      # Posts
      #----------------------------------------------------------------
      if data['graphql']['user']['edge_owner_to_timeline_media']
        postings << data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      postings.each do |posts|
        posts.each do |post|
          next if post.nil? || post['node'].nil?

          puts post['node']['shortcode']
          db_post = profile.instagram_posts.find_or_create_by!(shortcode: post['node']['shortcode'])
          response = InstagramServices::UpdatePostData.call(post)
          db_post.update!(response.data) if response.success?
          db_post.save_image(post['node']['display_url']) if db_post.image.nil?
        end
      end
    end
  end
end
