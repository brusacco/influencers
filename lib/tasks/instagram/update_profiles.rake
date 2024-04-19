# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles'
  task update_profiles: :environment do
    Parallel.each(Profile.where(updated_at: ..1.week.ago).order(followers: :desc), in_processes: 5) do |profile|
      next if profile.data.nil?

      puts "Updating profile #{profile.username}"

      data = InstagramServices::GetProfileData.call(profile.username)
      response = InstagramServices::UpdateProfileData.call(data.data)
      if response.success?
        profile.update!(response.data)
        profile.save_avatar #if profile.avatar.nil?
        sleep 1
      else
        puts "#{profile.username} #{response.error}"
      end
    rescue StandardError => e
      puts e.message
      retry
    end
  end
end
