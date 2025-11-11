# frozen_string_literal: true

namespace :instagram do
  desc 'Profile Posts crawler'
  task update_profile_posts: :environment do
    profile_id = ENV.fetch('PROFILE_ID', nil)
    
    unless profile_id
      puts "❌ Error: PROFILE_ID is required"
      puts "Usage: PROFILE_ID=123 rake instagram:update_profile_posts"
      exit
    end
    
    Profile.where(id: profile_id).find_each do |profile|
      puts "=" * 70
      puts "Profile: #{profile.username}"
      puts "Followers: #{profile.followers}"
      puts "Type: #{profile.profile_type}"
      puts "Enabled: #{profile.enabled ? '✓ Yes' : '✗ No (WARNING: Profile is disabled)'}"
      puts "=" * 70
      
      unless profile.enabled
        puts ""
        puts "⚠️  WARNING: This profile is currently disabled."
        puts "   It may not exist on Instagram or was manually disabled."
        puts "   Continue anyway? [y/N]: "
        response = STDIN.gets.chomp.downcase
        
        unless response == 'y' || response == 'yes'
          puts "Task cancelled."
          exit
        end
      end
      
      puts ""
      response = InstagramServices::GetPostsData.call(profile)
      next unless response.success?

      response.data.each_with_index do |edge, i|
        shortcode = edge['node']['shortcode']
        puts "#{shortcode} - #{profile.username} - #{profile.followers} - (#{i + 1} / #{response.data.size})"

        post_response = InstagramServices::UpdatePostData.call(edge, cursor: true)
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
