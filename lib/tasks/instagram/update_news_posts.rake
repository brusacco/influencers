# frozen_string_literal: true

namespace :instagram do
  desc 'Update media profile posts through Scrape.do API GraphQL'
  task update_news_posts: :environment do
    Rake::Task['instagram:update_news_posts_scrape_do_graphql'].invoke
  end
end
