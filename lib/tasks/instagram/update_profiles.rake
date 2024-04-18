# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles'
  task update_profiles: :environment do
    Profile.order(followers: :desc).each do |profile|
      next if profile.data.nil?

      puts "Updating profile #{profile.username}"

      response = InstagramServices::UpdateProfileData.call(profile.data)
      if response.success?
        profile.update!(response.data)
        profile.save_avatar if profile.avatar.nil?
      else
        puts "#{profile.username} #{response.error}"
      end
    rescue StandardError => e
      puts e.message
      retry
    end
  end
end
