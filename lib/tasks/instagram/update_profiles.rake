# frozen_string_literal: true

namespace :instagram do
  desc 'Update enabled Paraguayan profiles through Scrape.do API GraphQL (optional INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT)'
  task update_profiles: :environment do
    profiles = Profile.enabled.paraguayos.order(followers: :desc, id: :asc)
    profile_limit = ENV['INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT'].presence
    if profile_limit
      profile_limit = Integer(profile_limit, 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT must be positive' unless profile_limit.positive?

      profiles = profiles.limit(profile_limit)
    end

    total_count = profiles.count
    processed_profiles = 0
    updated_profiles = 0
    avatar_errors = 0
    errors = 0

    puts "Starting Scrape.do GraphQL profile update for #{total_count} profiles..."

    profiles.each do |profile|
      processed_profiles += 1
      puts "[#{processed_profiles}/#{total_count}] @#{profile.username}"

      fetched = InstagramServices::ScrapeDoGraphqlProfileFetcher.call(profile.username)
      unless fetched.success?
        puts "  x Fetch failed: #{fetched.error}"
        errors += 1
        next
      end

      persisted = InstagramServices::ScrapeDoGraphqlProfileUpserter.call(profile, fetched.data)
      unless persisted.success?
        puts "  x Update failed: #{persisted.error}"
        errors += 1
        next
      end

      begin
        profile.save_avatar if profile.profile_pic_url.present?
      rescue StandardError => e
        avatar_errors += 1
        puts "  ! Avatar update failed: #{e.message}"
      end

      updated_profiles += 1
      puts "  + Updated #{profile.followers} followers"
      sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
    end

    puts "Scrape.do GraphQL profile update complete: #{processed_profiles}/#{total_count} profiles, #{updated_profiles} updated, #{avatar_errors} avatar errors, #{errors} errors"
  end
end
