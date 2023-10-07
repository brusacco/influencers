# frozen_string_literal: true

namespace :instagram do
  desc 'Get users collabs'
  task collabs: :environment do
    InstagramPost.a_month_ago.find_each(batch_size: 50) do |post|
      puts post.shortcode
      next if post.data['node']['coauthor_producers'].nil?

      post.data['node']['coauthor_producers'].each do |coauthor|
        collaborated = Profile.find_by(username: coauthor['username'])
        collaborator = post.profile
        next unless collaborated

        puts "#{post.shortcode} - #{collaborated.username} - #{post.profile.username}"
        InstagramCollaboration.find_or_create_by!(
          instagram_post_id: post.id,
          collaborator_id: collaborator.id,
          collaborated_id: collaborated.id
        ) do |collab|
          collab.update!(posted_at: post.posted_at)
        end
      end
    end
  end
end
