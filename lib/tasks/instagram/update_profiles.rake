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
        # Profile data fetch failed - classify error type
        error_description = InstagramServices::ErrorClassifier.describe(data.error)
        
        case error_description[:type]
        when :permanent
          # Profile doesn't exist on Instagram anymore - disable it
          profile.update!(enabled: false)
          disabled_count += 1
          puts "  ✗ #{error_description[:user_message]}"
          puts "     Error: #{data.error}"
          
        when :temporary, :unknown
          # Temporary/unknown errors - don't disable, just log (be conservative)
          puts "  ⚠ #{error_description[:user_message]}"
          puts "     Error: #{data.error}"
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
