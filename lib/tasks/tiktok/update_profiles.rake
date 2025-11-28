# frozen_string_literal: true

namespace :tiktok do
  desc 'Update profiles'
  task update_profiles: :environment do
    profiles = TiktokProfile.enabled.paraguayos.order(followers: :desc).to_a
    total_count = profiles.count

    puts "Starting profile update for #{total_count} TikTok profiles..."
    puts "=" * 70

    # Use Parallel.map to collect results from each process
    results = Parallel.map(profiles, in_processes: 10) do |profile|
      next { status: :skipped } if profile.username.blank?

      puts "[#{Time.current.strftime('%H:%M:%S')}] Updating profile: #{profile.display_username}"

      begin
        # Step 1: Get raw data from API
        result = TiktokServices::GetProfileData.call(username: profile.username)

        if result.success?
          # Step 2: Transform raw data to profile attributes
          update_result = TiktokServices::UpdateProfileData.call(result.data)
          
          if update_result.success?
            # Step 3: Update model with transformed attributes
            profile.update!(update_result.data)
            profile.save_avatar
            puts "  ✓ Updated successfully"
            sleep 1
            { status: :updated }
          else
            puts "  ✗ Update failed: #{update_result.error}"
            { status: :error, type: :update_failed, message: update_result.error }
          end
        else
          # Profile data fetch failed - classify error type
          error_description = TiktokServices::ErrorClassifier.describe(result.error)
          
          case error_description[:type]
          when :permanent
            # Profile doesn't exist on TikTok anymore - disable it
            profile.update!(enabled: false)
            puts "  ✗ #{error_description[:user_message]}"
            puts "     Error: #{result.error}"
            { status: :disabled, message: result.error }
            
          when :temporary, :unknown
            # Temporary/unknown errors - don't disable, just log (be conservative)
            puts "  ⚠ #{error_description[:user_message]}"
            puts "     Error: #{result.error}"
            { status: :error, type: error_description[:type], message: result.error }
          end
        end
      rescue StandardError => e
        # Classify exception errors too
        error_description = TiktokServices::ErrorClassifier.describe(e.message)
        
        case error_description[:type]
        when :permanent
          profile.update!(enabled: false)
          puts "  ✗ #{error_description[:user_message]}"
          puts "     Exception: #{e.message}"
          { status: :disabled, message: e.message }
        else
          puts "  ✗ Exception: #{e.message}"
          { status: :error, type: :exception, message: e.message }
        end
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
    puts "⊘ Skipped (no username): #{skipped_count}" if skipped_count > 0
    puts "=" * 70
  end
end

