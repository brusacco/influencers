# frozen_string_literal: true

require 'parallel'

namespace :instagram do
  desc 'Update enabled Paraguayan profiles through Scrape.do API GraphQL (optional INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT and INSTAGRAM_SCRAPE_DO_CONCURRENCY)'
  task update_profiles: :environment do
    profiles = Profile.enabled.paraguayos.order(followers: :desc, id: :asc)
    profile_limit = ENV['INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT'].presence
    if profile_limit
      profile_limit = Integer(profile_limit, 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_PROFILE_LIMIT must be positive' unless profile_limit.positive?

      profiles = profiles.limit(profile_limit)
    end
    concurrency = Integer(ENV.fetch('INSTAGRAM_SCRAPE_DO_CONCURRENCY', '1'), 10)
    raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_CONCURRENCY must be between 1 and 10' unless concurrency.between?(1, 10)

    total_count = profiles.count
    updated_profiles = 0
    avatar_errors = 0
    errors = 0
    counters_lock = Mutex.new
    profile_ids = profiles.pluck(:id)

    puts "Starting Scrape.do GraphQL profile update for #{total_count} profiles (#{concurrency} worker#{'s' if concurrency != 1})..."

    Parallel.each(profile_ids.each_with_index.to_a, in_threads: concurrency) do |profile_id, index|
      ActiveRecord::Base.connection_pool.with_connection do
        profile = Profile.find(profile_id)
        profile_avatar_errors = 0

        puts "[#{index + 1}/#{total_count}] @#{profile.username}"

        fetched = InstagramServices::ScrapeDoGraphqlProfileFetcher.call(profile.username)
        unless fetched.success?
          puts "  x Fetch failed: #{fetched.error}"
          counters_lock.synchronize { errors += 1 }
          next
        end

        persisted = InstagramServices::ScrapeDoGraphqlProfileUpserter.call(profile, fetched.data)
        unless persisted.success?
          puts "  x Update failed: #{persisted.error}"
          counters_lock.synchronize { errors += 1 }
          next
        end

        begin
          if profile.profile_pic_url.present? && !profile.save_avatar
            profile_avatar_errors += 1
            puts '  ! Avatar update failed'
          end
        rescue StandardError => e
          profile_avatar_errors += 1
          puts "  ! Avatar update failed: #{e.message}"
        end

        counters_lock.synchronize do
          updated_profiles += 1
          avatar_errors += profile_avatar_errors
        end
        puts "  + Updated #{profile.followers} followers"
        sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
      end
    end

    puts "Scrape.do GraphQL profile update complete: #{total_count}/#{total_count} profiles, #{updated_profiles} updated, #{avatar_errors} avatar errors, #{errors} errors"
  end
end
