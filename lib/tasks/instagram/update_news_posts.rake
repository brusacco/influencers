# frozen_string_literal: true

namespace :instagram do
  desc 'News Posts crawler'
  task update_news_posts: :environment do
    profiles_count = Profile.medios.count
    processed_profiles = 0
    total_posts = 0
    error_count = 0
    
    puts "Starting news posts update for #{profiles_count} media profiles..."
    puts "=" * 70
    
    Parallel.each(Profile.medios.order(followers: :desc), in_processes: 10) do |profile|
      processed_profiles += 1
      puts "[#{Time.current.strftime('%H:%M:%S')}] [#{processed_profiles}/#{profiles_count}] #{profile.username} - #{profile.followers} followers"
      
      response = InstagramServices::GetPostsData.call(profile)
      
      unless response.success?
        error_message = response.error.to_s.downcase
        
        if error_message.include?('timeout') || error_message.include?('network error') || 
           error_message.include?('connection') || error_message.include?('attempts failed')
          puts "  ⚠ Temporary error (retries exhausted): #{response.error}"
        else
          puts "  ✗ Error: #{response.error}"
        end
        
        error_count += 1
        next
      end

      posts_updated = 0
      response.data.each_with_index do |edge, i|
        shortcode = edge['node']['shortcode']
        puts "  [#{i + 1}/#{response.data.size}] Processing: #{shortcode}"
        
        post_response = InstagramServices::UpdatePostData.call(edge, cursor: true)
        
        unless post_response.success?
          puts "    ✗ Failed to update: #{post_response.error}"
          next
        end

        post = profile.instagram_posts.find_or_create_by!(shortcode:)
        post.update!(post_response.data)

        begin
          post.save_image(edge['node']['display_url'])
          puts "    ✓ Updated successfully"
        rescue StandardError => e
          puts "    ⚠ Image save failed: #{e.message}"
        end
        
        posts_updated += 1
        total_posts += 1
      rescue StandardError => e
        puts "    ✗ Exception: #{e.message}"
        error_count += 1
        next
      end
      
      puts "  ✓ Updated #{posts_updated}/#{response.data.size} posts from #{profile.username}"
      puts "-" * 70
    end
    
    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "Profiles processed: #{processed_profiles}/#{profiles_count}"
    puts "✓ Total posts updated: #{total_posts}"
    puts "⚠ Errors encountered: #{error_count}"
    puts "=" * 70
  end
end
