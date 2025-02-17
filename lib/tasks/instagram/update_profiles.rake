# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles'
  task update_profiles: :environment do
    Parallel.each(Profile.paraguayos.order(followers: :desc), in_processes: 10) do |profile|
      next if profile.data.nil?

      puts "Updating profile #{profile.username}"

      data = InstagramServices::GetProfileData.call(profile.uid)
      response = InstagramServices::UpdateProfileData.call(data.data)
      if response.success?
        profile.update!(response.data)
        profile.save_avatar
        sleep 1
      else
        puts "#{profile.username} #{response.error}"
      end
    rescue StandardError => e
      puts e.message
      next
    end
  end
end
