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
        puts "  ✗ Error: #{response.error}"
        next { success: false, posts_updated: 0, posts_created: 0, errors: 1 }
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
          post.update_from_api_data(post_data)
          posts_updated += 1
          posts_created += 1 if was_new
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
    total_posts = results.sum { |r| r[:posts_updated] }
    total_errors = results.sum { |r| r[:errors] }

    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "Profiles processed: #{processed_profiles}/#{profiles_count}"
    puts "✓ Total posts updated: #{total_posts}"
    puts "⚠ Errors encountered: #{total_errors}"
    puts "=" * 70
  end
end

