# frozen_string_literal: true

namespace :instagram do
  desc 'Probe Instagram profile posts through Scrape.do API POST GraphQL without persisting data'
  task :probe_posts_scrape_do_graphql, [:username] => :environment do |_task, args|
    username = args[:username] || ENV['INSTAGRAM_USERNAME']
    result = InstagramServices::ScrapeDoGraphqlPostsFetcher.call(username)

    unless result.success?
      abort "Scrape.do GraphQL probe failed: #{result.error}"
    end

    shortcodes = result.data.filter_map { |node| node['code'] }
    puts "Scrape.do GraphQL probe succeeded for @#{username}: #{shortcodes.size} posts"
    puts shortcodes.join(', ')
  end
end
