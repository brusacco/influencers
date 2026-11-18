# frozen_string_literal: true

namespace :instagram do
  desc 'Update Instagram posts through Ferrum (direct by default; optional Scrape.do proxy)'
  task update_posts_ferrum: :environment do
    profiles = Profile.tracked.order(followers: :desc)
    profile_limit = ENV['INSTAGRAM_FERRUM_PROFILE_LIMIT'].presence
    if profile_limit
      profile_limit = Integer(profile_limit, 10)
      raise ArgumentError, 'INSTAGRAM_FERRUM_PROFILE_LIMIT must be positive' unless profile_limit.positive?

      profiles = profiles.limit(profile_limit)
    end

    profiles_count = profiles.count
    processed_profiles = 0
    updated_posts = 0
    errors = 0

    puts "Starting Ferrum post update for #{profiles_count} tracked profiles..."

    profiles.find_each do |profile|
      processed_profiles += 1
      puts "[#{processed_profiles}/#{profiles_count}] @#{profile.username}"

      result = InstagramServices::FerrumPostsFetcher.call(profile)
      unless result.success?
        puts "  x Fetch failed: #{result.error}"
        errors += 1
        next
      end

      result.data.each do |attributes|
        persisted = InstagramServices::FerrumPostUpserter.call(profile, attributes)
        if persisted.success?
          updated_posts += 1
        else
          puts "  x Post #{attributes[:shortcode]} failed: #{persisted.error}"
          errors += 1
        end
      end

      puts "  + Updated #{result.data.size} posts"
      sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
    end

    puts "Ferrum update complete: #{processed_profiles}/#{profiles_count} profiles, #{updated_posts} posts, #{errors} errors"
  end
end
