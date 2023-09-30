# frozen_string_literal: true

namespace :instagram do
  desc 'Get users collabs'
  task collabs: :environment do
    Profile.order(followers: :desc).each do |profile|
      # puts profile.username
      # puts '----------------------------------'

      data = JSON.parse(profile.data)

      postings = []

      #----------------------------------------------------------------
      # Videos
      #----------------------------------------------------------------
      if data['graphql']['user']['edge_felix_video_timeline']
        postings << data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      #----------------------------------------------------------------
      # Posts
      #----------------------------------------------------------------
      if data['graphql']['user']['edge_owner_to_timeline_media']
        postings << data['graphql']['user']['edge_felix_video_timeline']['edges']
      end

      postings.each do |posts|
        posts.each do |post|
          next if post.nil? || post['node'].nil?

          next unless post['node']['coauthor_producers']

          post['node']['coauthor_producers'].each do |coauthor|
            puts ">>> #{coauthor['username']}"
            Profile.find_or_create_by!(username: coauthor['username'])
          end
        end
      end
    rescue StandardError => e
      puts e.message
      profile.update_profile
      nextaa
    end
  end
end
