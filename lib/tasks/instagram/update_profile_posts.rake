# frozen_string_literal: true

namespace :instagram do
  desc 'Profile Posts crawler'
  task update_profile_posts: :environment do
    profile_id = ENV.fetch('PROFILE_ID', nil)
    puts profile_id
    Profile.where(id: profile_id).find_each do |profile|
      puts "#{profile.username} - #{profile.followers} - #{profile.profile_type}"
      response = InstagramServices::GetPostsData.call(profile)
      next unless response.success?

      response.data.each_with_index do |edge, i|
        shortcode = edge['node']['shortcode']
        puts "#{shortcode} - #{profile.username} - #{profile.followers} - (#{i + 1} / #{response.data.size})"

        post_response = InstagramServices::UpdatePostData.call(edge, true)
        next unless post_response.success?

        post = profile.instagram_posts.find_or_create_by!(shortcode:)
        post.update!(post_response.data)

        begin
          post.save_image(edge['node']['display_url'])
        rescue StandardError => e
          puts e.message
        end
        profile.touch # rubocop:disable Rails/SkipsModelValidations
        puts '---------------------------------------'
      rescue StandardError => e
        puts e.message
        next
      end
    end
  end
end
