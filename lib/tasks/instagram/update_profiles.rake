# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles'
  task update_profiles: :environment do
    disabled_count = 0
    updated_count = 0
    error_count = 0
    
    puts "Starting profile update for #{Profile.enabled.paraguayos.count} profiles..."
    puts "=" * 70
    
    Parallel.each(Profile.enabled.paraguayos.order(followers: :desc), in_processes: 10) do |profile|
      next if profile.data.nil?

      puts "[#{Time.current.strftime('%H:%M:%S')}] Updating profile: #{profile.username}"

      data = InstagramServices::GetProfileData.call(profile.username)
      
      if data.success?
        response = InstagramServices::UpdateProfileData.call(data.data)
        if response.success?
          profile.update!(response.data)
          profile.save_avatar
          updated_count += 1
          puts "  ✓ Updated successfully"
          sleep 1
        else
          puts "  ✗ Update failed: #{response.error}"
          error_count += 1
        end
      else
        # Profile data fetch failed - check if profile no longer exists
        error_message = data.error.to_s.downcase
        
        if error_message.include?('404') || 
           error_message.include?('not found') || 
           error_message.include?('user does not exist') ||
           error_message.include?("doesn't exist") ||
           error_message.include?('deleted') ||
           error_message.include?('invalid response structure: missing user data')
          
          # Profile doesn't exist on Instagram anymore - disable it
          profile.update!(enabled: false)
          disabled_count += 1
          puts "  ✗ Profile not found on Instagram - DISABLED"
          puts "     Error: #{data.error}"
        else
          # Other error (timeout, API error, etc.) - don't disable
          puts "  ⚠ Temporary error (not disabling): #{data.error}"
          error_count += 1
        end
      end
    rescue StandardError => e
      puts "  ✗ Exception: #{e.message}"
      error_count += 1
      next
    end
    
    # Summary
    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "✓ Successfully updated: #{updated_count}"
    puts "✗ Disabled (not found): #{disabled_count}"
    puts "⚠ Errors (temporary):  #{error_count}"
    puts "=" * 70
  end
end
