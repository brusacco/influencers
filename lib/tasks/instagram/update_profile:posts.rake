# frozen_string_literal: true

namespace :instagram do
  desc 'Profile Posts crawler'
  task update_profile_posts: :environment do
    profile_id = ENV.fetch('PROFILE_ID', nil)
    puts profile_id
    Profile.where(id: profile_id).order(followers: :desc) do |profile|
      puts "#{profile.username} - #{profile.followers}"
      response = InstagramServices::GetPostsData.call(profile)
      next unless response.success?

      response.data.each do |edge|
        shortcode = edge['node']['shortcode']
        puts "#{shortcode} - #{profile.username} - #{profile.followers}"

        post_response = InstagramServices::UpdatePostData.call(edge, true)
        next unless post_response.success?

        post = profile.instagram_posts.find_or_create_by!(shortcode: shortcode)
        post.update!(post_response.data)

        begin
          post.save_image(edge['node']['display_url']) unless post.image.attached?
        rescue StandardError => e
          puts e.message
        end
        puts '---------------------------------------'
      rescue StandardError => e
        puts e.message
        next
      end
    end
  end
end
