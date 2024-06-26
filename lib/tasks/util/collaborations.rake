# frozen_string_literal: true

namespace :util do
  desc 'Generate collaborations'
  task collaborations: :environment do
    InstagramPost.a_month_ago.each do |post|
      next if InstagramCollaboration.exists?(instagram_post: post)
      next if post.data.empty?
      next if post.profile.followers < 40_000
      next unless post.profile.country_string == 'Paraguay'
      next unless post.data['node']['coauthor_producers']

      puts "Generating collaborations for #{post.shortcode} - #{post.profile.username}"
      post.data['node']['coauthor_producers'].each do |coauthor|
        coauthor = coauthor['username']
        next if coauthor == post.profile.username

        collaborated_profile = Profile.find_or_create_by!(username: coauthor)

        InstagramCollaboration.create!(
          instagram_post: post,
          collaborator: post.profile,
          collaborated: collaborated_profile,
          created_at: post.posted_at
        )
      rescue StandardError => e
        puts e.message
      end
      puts '----------------------------------------------------'
    end
  end
end
