# frozen_string_literal: true

namespace :util do
  desc 'Add Mentioned profiles to DB'
  task add_mentions_profiles: :environment do
    Profile.paraguayos.where(followers: 50_000..).find_each do |profile|
      puts "Adding profiles related to #{profile.username}"
      profile.mentions.each do |mention|
        Profile.find_or_create_by(username: mention) do |p|
          puts "Adding >>> #{p.username} to DB"
        end
      end
    rescue StandardError => e
      puts e.message
      sleep 5
      next
    end
  end
end
