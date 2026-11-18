# frozen_string_literal: true

require 'parallel'

namespace :instagram do
  desc 'Update tracked Instagram posts through Scrape.do API GraphQL (optional CHECK_INACTIVE=1, INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT, and INSTAGRAM_SCRAPE_DO_CONCURRENCY)'
  task update_posts: :environment do
    check_inactive = ENV['CHECK_INACTIVE'] == '1'
    profiles = if check_inactive
                 Profile.paraguayos.micro.where.not(profile_type: :medio)
               else
                 Profile.tracked.where.not(profile_type: :medio)
               end
    profiles = profiles.reorder(followers: :desc, id: :asc)
    profile_limit = ENV['INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT'].presence
    if profile_limit
      profile_limit = Integer(profile_limit, 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT must be positive' unless profile_limit.positive?

      profiles = profiles.limit(profile_limit)
    end
    concurrency = Integer(ENV.fetch('INSTAGRAM_SCRAPE_DO_CONCURRENCY', '1'), 10)
    raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_CONCURRENCY must be between 1 and 10' unless concurrency.between?(1, 10)

    profiles_count = profiles.count
    imported_posts = 0
    enabled_profiles = 0
    errors = 0
    counters_lock = Mutex.new
    profile_ids = profiles.pluck(:id)

    puts "Starting Scrape.do GraphQL update for #{profiles_count} tracked profiles (#{concurrency} worker#{'s' if concurrency != 1})..."

    Parallel.each(profile_ids.each_with_index.to_a, in_threads: concurrency) do |profile_id, index|
      ActiveRecord::Base.connection_pool.with_connection do
        profile = Profile.find(profile_id)
        profile_imported_posts = 0
        profile_enabled = 0
        profile_errors = 0

        puts "[#{index + 1}/#{profiles_count}] @#{profile.username}"

        if check_inactive && !profile.enabled?
          profile.update!(enabled: true)
          profile_enabled += 1
          puts '  + Enabled inactive profile for verification'
        end

        fetched = InstagramServices::ScrapeDoGraphqlPostsFetcher.call(profile.username)
        unless fetched.success?
          puts "  x Fetch failed: #{fetched.error}"
          if check_inactive && fetched.error == 'Instagram did not expose the profile posts GraphQL query'
            profile.update!(enabled: false)
            puts '  - Disabled profile: public post grid is unavailable'
          end
          counters_lock.synchronize { errors += 1; enabled_profiles += profile_enabled }
          next
        end

        fetched.data.each do |node|
          result = InstagramServices::ScrapeDoGraphqlPostUpserter.call(profile, node)
          if result.success?
            profile_imported_posts += 1
          else
            puts "  x Post #{node['code']} failed: #{result.error}"
            profile_errors += 1
          end
        end

        counters_lock.synchronize do
          imported_posts += profile_imported_posts
          enabled_profiles += profile_enabled
          errors += profile_errors
        end
        puts "  + Updated #{fetched.data.size} posts"
        sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
      end
    end

    puts "Scrape.do GraphQL update complete: #{profiles_count}/#{profiles_count} profiles, #{enabled_profiles} enabled, #{imported_posts} posts, #{errors} errors"
  end
end
