# frozen_string_literal: true

namespace :instagram do
  desc 'Update one profile post grid through Scrape.do API GraphQL (username required)'
  task :update_posts_scrape_do_graphql, [:username] => :environment do |_task, args|
    username = args[:username] || ENV['INSTAGRAM_USERNAME']
    abort 'Provide a username: rake instagram:update_posts_scrape_do_graphql[username]' if username.blank?

    Rake::Task['instagram:import_posts_scrape_do_graphql'].invoke(username)
  end
end
