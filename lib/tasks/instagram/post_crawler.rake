# frozen_string_literal: true

namespace :instagram do
  desc 'Posts crawler'
  task post_crawler: :environment do
    Profile.where.not(uid: nil).find_each do |profile|
      puts profile.username
      response = InstagramServices::GetPostsData.call(profile)
      next unless response.success?

      response.data['data']['user']['edge_owner_to_timeline_media']['edges'].each do |edge|
        puts edge['node']['shortcode']
        post_response = InstagramServices::UpdatePostData.call(edge, true)
        next unless post_response.success?

        post = profile.instagram_posts.find_or_create_by!(shortcode: edge['node']['shortcode'])
        post.update!(post_response.data)
        begin
          post.save_image(edge['node']['display_url']) unless post.image.attached?
        rescue StandardError => e
          puts e.message
        end
        post.update_total_count

        puts '---------------------------------------'
      rescue StandardError => e
        puts e.message
        next
      end
    end
  end
end
