# frozen_string_literal: true

namespace :instagram do
  desc 'Top accounts crawler'
  task crawler_top: :environment do
    Parallel.each(Profile.where(followers: 50_000.., country_string: 'Paraguay').order(followers: :desc).limit(1), in_threads: 5) do |profile|
      puts profile.username
      puts '----------------------------------'

      #----------------------------------------------------------------
      # Update JSON Data
      #----------------------------------------------------------------
      response = InstagramServices::GetProfileData.call(profile.username)
      next unless response.success?

      profile.update!(response.data)

      #----------------------------------------------------------------
      # Update DB Data
      #----------------------------------------------------------------
      response = InstagramServices::UpdateProfileData.call(profile.data)
      next unless response.success?

      profile.update!(response.data)
      profile.save_avatar # unless profile.avatar.attached?

      data = profile.data
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
        postings << data['graphql']['user']['edge_owner_to_timeline_media']['edges']
      end

      postings.each do |posts|
        posts.each do |post|
          next if post.nil? || post['node'].nil?

          puts "#{post['node']['shortcode']} - #{post['node']['taken_at_timestamp']} - #{Time.zone.at(Integer(post['node']['taken_at_timestamp']))} - #{post['node']['__typename']}"
          db_post = profile.instagram_posts.find_or_create_by!(shortcode: post['node']['shortcode'])
          response = InstagramServices::UpdatePostData.call(post)
          next unless response.success?

          db_post.update!(response.data)
          db_post.save_image(post['node']['display_url']) unless db_post.image.attached?
          db_post.update_total_count
        end
      end

      #----------------------------------------------------------------
      # Pagination Feed
      #----------------------------------------------------------------
      # user_id = data['graphql']['user']['id']
      # cursor = data['graphql']['user']['edge_owner_to_timeline_media']['page_info']['end_cursor']
      # response = InstagramServices::GetProfileCursor.call(user_id, cursor)
      # next unless response.success?

      # data_cursor = response.data
      # posts = data_cursor['data']['user']['edge_owner_to_timeline_media']['edges']

      # posts.each do |post|
      #   next if post.nil? || post['node'].nil?

      #   puts "#{post['node']['shortcode']} - #{post['node']['taken_at_timestamp']} - #{Time.zone.at(Integer(post['node']['taken_at_timestamp']))} - #{post['node']['__typename']}"
      #   db_post = profile.instagram_posts.find_or_create_by!(shortcode: post['node']['shortcode'])
      #   response = InstagramServices::UpdatePostData.call(post, true)
      #   if response.success?
      #     db_post.update!(response.data)
      #     db_post.save_image(post['node']['display_url']) if db_post.image.attached?
      #     db_post.update_total_count
      #   else
      #     puts response.error
      #   end
      # end

      #----------------------------------------------------------------
      # Pagination Videos
      #----------------------------------------------------------------
      # user_id = data['graphql']['user']['id']
      # cursor = data['graphql']['user']['edge_felix_video_timeline']['page_info']['end_cursor']
      # response = InstagramServices::GetProfileCursor.call(user_id, cursor)
      # next unless response.success?

      # data_cursor = response.data
      # posts = data_cursor['data']['user']['edge_owner_to_timeline_media']['edges']

      # posts.each do |post|
      #   next if post.nil? || post['node'].nil?

      #   puts "#{post['node']['shortcode']} - #{post['node']['taken_at_timestamp']} - #{Time.at(Integer(post['node']['taken_at_timestamp']))} - #{post['node']['__typename']}"
      #   db_post = profile.instagram_posts.find_or_create_by!(shortcode: post['node']['shortcode'])
      #   response = InstagramServices::UpdatePostData.call(post, true)
      #   if response.success?
      #     db_post.update!(response.data)
      #     db_post.save_image(post['node']['display_url']) if db_post.image.nil?
      #     db_post.update_total_count
      #   else
      #     puts response.error
      #   end
      # end
    rescue StandardError => e
      puts e.message
      next
    end
  end
end
