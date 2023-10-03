# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles stats'
  task update_profiles_stats: :environment do
    Profile.all.order(followers: :desc).each do |profile|
      puts "Updating stats for #{profile.username}"
      profile.update_profiles_stats
    rescue StandardError => e
      puts e.message
      next
    end
  end
end
