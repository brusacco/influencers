# frozen_string_literal: true

namespace :instagram do
  desc 'Import one profile post grid through Scrape.do API GraphQL'
  task :import_posts_scrape_do_graphql, [:username] => :environment do |_task, args|
    username = args[:username] || ENV['INSTAGRAM_USERNAME']
    profile = Profile.find_by!(username:)
    fetched = InstagramServices::ScrapeDoGraphqlPostsFetcher.call(profile.username)
    abort "Scrape.do GraphQL import failed: #{fetched.error}" unless fetched.success?

    imported = 0
    errors = 0

    fetched.data.each do |node|
      result = InstagramServices::ScrapeDoGraphqlPostUpserter.call(profile, node)
      if result.success?
        imported += 1
      else
        errors += 1
        puts "  x #{node['code']}: #{result.error}"
      end
    end

    puts "Scrape.do GraphQL import complete for @#{profile.username}: #{imported} posts, #{errors} errors"
  end
end
