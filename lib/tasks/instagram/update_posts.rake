# frozen_string_literal: true

namespace :instagram do
  desc 'Update tracked Instagram posts through Scrape.do API GraphQL (optional CHECK_INACTIVE=1 and INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT)'
  task update_posts: :environment do
    check_inactive = ENV['CHECK_INACTIVE'] == '1'
    profiles = if check_inactive
                 Profile.paraguayos.micro.order(followers: :desc)
               else
                 Profile.tracked.order(followers: :desc)
               end
    profile_limit = ENV['INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT'].presence
    if profile_limit
      profile_limit = Integer(profile_limit, 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT must be positive' unless profile_limit.positive?

      profiles = profiles.limit(profile_limit)
    end

    profiles_count = profiles.count
    processed_profiles = 0
    imported_posts = 0
    enabled_profiles = 0
    errors = 0

    puts "Starting Scrape.do GraphQL update for #{profiles_count} tracked profiles..."

    profiles.find_each do |profile|
      processed_profiles += 1
      puts "[#{processed_profiles}/#{profiles_count}] @#{profile.username}"

      if check_inactive && !profile.enabled?
        profile.update!(enabled: true)
        enabled_profiles += 1
        puts '  + Enabled inactive profile for verification'
      end

      fetched = InstagramServices::ScrapeDoGraphqlPostsFetcher.call(profile.username)
      unless fetched.success?
        puts "  x Fetch failed: #{fetched.error}"
        if check_inactive && fetched.error == 'Instagram did not expose the profile posts GraphQL query'
          profile.update!(enabled: false)
          puts '  - Disabled profile: public post grid is unavailable'
        end
        errors += 1
        next
      end

      fetched.data.each do |node|
        result = InstagramServices::ScrapeDoGraphqlPostUpserter.call(profile, node)
        if result.success?
          imported_posts += 1
        else
          puts "  x Post #{node['code']} failed: #{result.error}"
          errors += 1
        end
      end

      puts "  + Updated #{fetched.data.size} posts"
      sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
    end

    puts "Scrape.do GraphQL update complete: #{processed_profiles}/#{profiles_count} profiles, #{enabled_profiles} enabled, #{imported_posts} posts, #{errors} errors"
  end
end
