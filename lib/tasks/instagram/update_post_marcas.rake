# frozen_string_literal: true

namespace :instagram do
  desc 'Brand Posts crawler'
  task update_posts_marcas: :environment do
    profiles_count = Profile.marcas.count
    processed_profiles = 0
    total_posts = 0
    error_count = 0

    puts "Starting brand posts update for #{profiles_count} brand profiles..."
    puts '=' * 70

    Parallel.each(Profile.marcas.order(followers: :desc), in_processes: 10) do |profile|
      processed_profiles += 1
      puts "[#{Time.current.strftime('%H:%M:%S')}] [#{processed_profiles}/#{profiles_count}] #{profile.username} - #{profile.followers} followers"

      response = InstagramServices::GetPostsData.call(profile)

      unless response.success?
        error_description = InstagramServices::ErrorClassifier.describe(response.error)

        case error_description[:type]
        when :temporary
          puts "  ⚠ #{error_description[:user_message]}: #{response.error}"
        else
          puts "  ✗ Error: #{response.error}"
        end

        error_count += 1
        next
      end

      posts_updated = 0
      response.data.each do |node|
        shortcode = node['code']

        post_response = InstagramServices::ScrapeDoGraphqlPostUpserter.call(profile, node)

        unless post_response.success?
          puts "  ✗ Failed to update post #{shortcode}: #{post_response.error}"
          next
        end

        posts_updated += 1
        total_posts += 1
      rescue StandardError => e
        puts "  ✗ Exception on post #{shortcode}: #{e.message}"
        error_count += 1
        next
      end

      puts "  ✓ Updated #{posts_updated} posts"
      puts '-' * 70
    end

    puts ''
    puts '=' * 70
    puts 'UPDATE SUMMARY'
    puts '=' * 70
    puts "Profiles processed: #{processed_profiles}/#{profiles_count}"
    puts "✓ Total posts updated: #{total_posts}"
    puts "⚠ Errors encountered: #{error_count}"
    puts '=' * 70
  end
end
