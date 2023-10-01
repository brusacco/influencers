# frozen_string_literal: true

namespace :instagram do
  desc 'Update/Create Instagram posts'
  task update_posts: :environment do
    InstagramPost.all.each do |post|
      puts post.shortcode
      data = JSON.parse(post.data)
    end
  end
end
