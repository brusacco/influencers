# frozen_string_literal: true

namespace :tiktok do
  desc 'Posts crawler'
  task update_posts: :environment do
    profiles = TiktokProfile.tracked.order(followers: :desc).to_a
    profiles_count = profiles.count

    puts "Starting posts update for #{profiles_count} tracked TikTok profiles..."
    puts "=" * 70

    results = Parallel.map_with_index(profiles, in_processes: 5) do |profile, index|
      profile_num = index + 1
      puts "[#{Time.current.strftime('%H:%M:%S')}] [#{profile_num}/#{profiles_count}] #{profile.display_username} - #{profile.followers} followers"

      response = TiktokServices::GetPostsData.call(profile)

      unless response.success?
        # Classify error type
        error_description = TiktokServices::ErrorClassifier.describe(response.error)
        
        case error_description[:type]
        when :permanent
          # Profile doesn't exist on TikTok anymore - disable it
          profile.update!(enabled: false)
          puts "  ✗ #{error_description[:user_message]}"
          puts "     Error: #{response.error}"
          next { success: false, posts_updated: 0, posts_created: 0, errors: 1, disabled: true }
        when :temporary, :unknown
          # Temporary/unknown errors - don't disable, just log
          puts "  ⚠ #{error_description[:user_message]}"
          puts "     Error: #{response.error}"
          next { success: false, posts_updated: 0, posts_created: 0, errors: 1 }
        end
      end

      posts_updated = 0
      posts_created = 0
      post_errors = 0

      response.data.each do |post_data|
        post_id = post_data['id']
        next if post_id.blank?

        post = profile.tiktok_posts.find_or_initialize_by(tiktok_post_id: post_id)
        was_new = post.new_record?

        begin
          # Use UpdatePostData service to transform raw data
          update_result = TiktokServices::UpdatePostData.call(post_data)
          
          if update_result.success?
            # Update model with transformed attributes
            post.update!(update_result.data)
            post.save_cover
            posts_updated += 1
            posts_created += 1 if was_new
          else
            puts "  ✗ Failed to transform post #{post_id}: #{update_result.error}"
            post_errors += 1
          end
        rescue StandardError => e
          puts "  ✗ Exception on post #{post_id}: #{e.message}"
          post_errors += 1
          next
        end
      end

      puts "  ✓ Updated #{posts_updated} posts (#{posts_created} new)"
      puts "-" * 70

      { success: true, posts_updated: posts_updated, posts_created: posts_created, errors: post_errors }
    end

    # Aggregate results
    results.compact!
    processed_profiles = results.count
    total_posts = results.sum { |r| r[:posts_updated] || 0 }
    total_errors = results.sum { |r| r[:errors] || 0 }
    disabled_profiles = results.count { |r| r[:disabled] == true }

    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "Profiles processed: #{processed_profiles}/#{profiles_count}"
    puts "✓ Total posts updated: #{total_posts}"
    puts "✗ Profiles disabled (not found): #{disabled_profiles}" if disabled_profiles > 0
    puts "⚠ Errors encountered: #{total_errors}"
    puts "=" * 70
  end
end

