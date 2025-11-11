# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles'
  task update_profiles: :environment do
    profiles = Profile.enabled.paraguayos.order(followers: :desc).to_a
    total_count = profiles.count
    
    puts "Starting profile update for #{total_count} profiles..."
    puts "=" * 70
    
    # Use Parallel.map to collect results from each process
    results = Parallel.map(profiles, in_processes: 10) do |profile|
      next { status: :skipped } if profile.data.nil?

      puts "[#{Time.current.strftime('%H:%M:%S')}] Updating profile: #{profile.username}"

      begin
        data = InstagramServices::GetProfileData.call(profile.username)
        
        if data.success?
          response = InstagramServices::UpdateProfileData.call(data.data)
          if response.success?
            profile.update!(response.data)
            profile.save_avatar
            puts "  ✓ Updated successfully"
            sleep 1
            { status: :updated }
          else
            puts "  ✗ Update failed: #{response.error}"
            { status: :error, type: :update_failed, message: response.error }
          end
        else
          # Profile data fetch failed - classify error type
          error_description = InstagramServices::ErrorClassifier.describe(data.error)
          
          case error_description[:type]
          when :permanent
            # Profile doesn't exist on Instagram anymore - disable it
            profile.update!(enabled: false)
            puts "  ✗ #{error_description[:user_message]}"
            puts "     Error: #{data.error}"
            { status: :disabled, message: data.error }
            
          when :temporary, :unknown
            # Temporary/unknown errors - don't disable, just log (be conservative)
            puts "  ⚠ #{error_description[:user_message]}"
            puts "     Error: #{data.error}"
            { status: :error, type: error_description[:type], message: data.error }
          end
        end
      rescue StandardError => e
        puts "  ✗ Exception: #{e.message}"
        { status: :error, type: :exception, message: e.message }
      end
    end
    
    # Count results from all processes
    updated_count = results.count { |r| r[:status] == :updated }
    disabled_count = results.count { |r| r[:status] == :disabled }
    error_count = results.count { |r| r[:status] == :error }
    skipped_count = results.count { |r| r[:status] == :skipped }
    
    # Summary
    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "Total profiles: #{total_count}"
    puts "✓ Successfully updated: #{updated_count}"
    puts "✗ Disabled (not found): #{disabled_count}"
    puts "⚠ Errors (temporary):  #{error_count}"
    puts "⊘ Skipped (no data):   #{skipped_count}" if skipped_count > 0
    puts "=" * 70
  end
end
