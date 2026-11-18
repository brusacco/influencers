# frozen_string_literal: true

require 'parallel'
require_relative 'scrape_do_task_lock'

namespace :instagram do
  desc 'Populate up to 1,000 newest missing Instagram post publication dates through Scrape.do GraphQL (optional INSTAGRAM_SCRAPE_DO_POST_LIMIT and INSTAGRAM_SCRAPE_DO_CONCURRENCY)'
  task update_missing_posted_at: :environment do
    lock = InstagramScrapeDoTaskLock.acquire('instagram-update-missing-posted-at')
    unless lock
      puts 'Skipping missing publication date update: another run is still active'
      next
    end

    begin
      post_limit = Integer(ENV.fetch('INSTAGRAM_SCRAPE_DO_POST_LIMIT', '1000'), 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_POST_LIMIT must be between 1 and 1000' unless post_limit.between?(1, 1000)

      posts = InstagramPost.where(posted_at: nil).order(id: :desc).limit(post_limit)
      concurrency = Integer(ENV.fetch('INSTAGRAM_SCRAPE_DO_CONCURRENCY', '5'), 10)
      raise ArgumentError, 'INSTAGRAM_SCRAPE_DO_CONCURRENCY must be between 1 and 10' unless concurrency.between?(1, 10)

      post_ids = posts.pluck(:id)
      updated = 0
      errors = 0
      counters_lock = Mutex.new

      puts "Starting missing publication date update for #{post_ids.size} posts (#{concurrency} worker#{'s' if concurrency != 1})..."

      Parallel.each(post_ids.each_with_index.to_a, in_threads: concurrency) do |post_id, index|
        ActiveRecord::Base.connection_pool.with_connection do
          post = InstagramPost.find(post_id)
          puts "[#{index + 1}/#{post_ids.size}] #{post.shortcode}"

          result = InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.call(post)
          unless result.success?
            puts "  x Fetch failed: #{result.error}"
            counters_lock.synchronize { errors += 1 }
            next
          end

          post.update!(posted_at: result.data)
          counters_lock.synchronize { updated += 1 }
          puts "  + Updated #{result.data.iso8601}"
          sleep InstagramConfig::FERRUM_PAUSE_SECONDS if InstagramConfig::FERRUM_PAUSE_SECONDS.positive?
        end
      end

      puts "Missing publication date update complete: #{updated}/#{post_ids.size} updated, #{errors} errors"
    ensure
      lock.flock(File::LOCK_UN)
      lock.close
    end
  end
end
