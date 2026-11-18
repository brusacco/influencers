# frozen_string_literal: true

namespace :instagram do
  desc 'Update Instagram posts through the public GraphQL browser flow'
  task update_posts: :environment do
    Rake::Task['instagram:update_posts_ferrum'].invoke
  end
end
