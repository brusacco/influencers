# frozen_string_literal: true

namespace :instagram do
  desc 'Get users collabs'
  task collabs: :environment do
    Profile.where(followers: 500_000..).order(followers: :desc).each do |profile|
      puts profile.username
      puts '----------------------------------'
      puts profile.collaborations
      profile.collaborations.each do |collab|
        Profile.find_or_create_by!(username: collab)
      end
    rescue StandardError => e
      puts e.message
      profile.update_profile
      next
    end
  end
end
