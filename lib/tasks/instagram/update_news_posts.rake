# frozen_string_literal: true

namespace :instagram do
  desc 'News Posts crawler'
  task update_news_posts: :environment do
    Parallel.each(Profile.medios.order(followers: :desc), in_processes: 10) do |profile|
      puts "#{profile.username} - #{profile.followers}"
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
        puts '---------------------------------------'
      rescue StandardError => e
        puts e.message
        next
      end
    end
  end
end
