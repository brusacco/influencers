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
        result = TiktokServices::GetProfileData.call(username: profile.username)

        if result.success?
          profile.update_from_api_data(result.data)
          puts "  ✓ Updated successfully"
          sleep 1
          { status: :updated }
        else
          puts "  ✗ Update failed: #{result.error}"
          { status: :error, type: :update_failed, message: result.error }
        end
      rescue StandardError => e
        puts "  ✗ Exception: #{e.message}"
        { status: :error, type: :exception, message: e.message }
      end
    end

    # Count results from all processes
    updated_count = results.count { |r| r[:status] == :updated }
    error_count = results.count { |r| r[:status] == :error }
    skipped_count = results.count { |r| r[:status] == :skipped }

    # Summary
    puts ""
    puts "=" * 70
    puts "UPDATE SUMMARY"
    puts "=" * 70
    puts "Total profiles: #{total_count}"
    puts "✓ Successfully updated: #{updated_count}"
    puts "⚠ Errors: #{error_count}"
    puts "⊘ Skipped (no username): #{skipped_count}" if skipped_count > 0
    puts "=" * 70
  end
end

