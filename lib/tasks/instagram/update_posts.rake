# frozen_string_literal: true

namespace :instagram do
  desc 'Posts crawler'
  task update_posts: :environment do
    Parallel.each(Profile.tracked.order(followers: :desc), in_processes: 10) do |profile|
      puts "#{profile.username} - #{profile.followers}"
      response = InstagramServices::GetPostsData.call(profile)
      next unless response.success?

      response.data.each do |edge|
        shortcode = edge['node']['shortcode']
        puts "#{shortcode} - #{profile.username} - #{profile.followers}"

        post_response = InstagramServices::UpdatePostData.call(edge, true)
        next unless post_response.success?

        post = profile.instagram_posts.find_or_create_by!(shortcode:)
        post.update!(post_response.data)
        post.save_image(edge['node']['display_resources'][0]['src'])
        puts '---------------------------------------'
      rescue StandardError => e
        puts e.message
        next
      end
    end
  end
end
