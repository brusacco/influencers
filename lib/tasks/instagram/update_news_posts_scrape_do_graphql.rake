# frozen_string_literal: true

namespace :instagram do
  desc 'Update and enable media profile posts through Scrape.do API GraphQL (optional INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT)'
  task update_news_posts_scrape_do_graphql: :environment do
    profiles = Profile.paraguayos.where(profile_type: :medio).order(followers: :desc)
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

    puts "Starting Scrape.do GraphQL update for #{profiles_count} media profiles..."

    profiles.find_each do |profile|
      processed_profiles += 1
      puts "[#{processed_profiles}/#{profiles_count}] @#{profile.username}"

      unless profile.enabled?
        profile.update!(enabled: true)
        enabled_profiles += 1
        puts '  + Enabled profile'
      end

      fetched = InstagramServices::ScrapeDoGraphqlPostsFetcher.call(profile.username)
      unless fetched.success?
        puts "  x Fetch failed: #{fetched.error}"
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

    puts "Scrape.do GraphQL update complete: #{processed_profiles}/#{profiles_count} media profiles, #{enabled_profiles} enabled, #{imported_posts} posts, #{errors} errors"
  end
end
