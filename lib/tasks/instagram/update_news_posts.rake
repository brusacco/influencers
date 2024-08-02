# frozen_string_literal: true

namespace :instagram do
  desc 'News Posts crawler'
  task update_news_posts: :environment do
    Parallel.each(Profile.paraguayos.where(profile_type: :medio).order(followers: :desc), in_processes: 10) do |profile|
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
          post.save_image(edge['node']['display_resources'][0]['src'])
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
