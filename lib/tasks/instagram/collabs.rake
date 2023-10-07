# frozen_string_literal: true

namespace :instagram do
  desc 'Get users collabs'
  task collabs: :environment do
    InstagramPost.all.each do |post|
      next unless post.data['node']['coauthor_producers']

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
