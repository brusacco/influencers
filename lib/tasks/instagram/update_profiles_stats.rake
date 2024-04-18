# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles stats'
  task update_profiles_stats: :environment do
    Profile.order(followers: :desc).each do |profile|
      puts "Updating stats for #{profile.username}"
      profile.update_profile_stats
    end
  end
end
