# frozen_string_literal: true

namespace :instagram do
  desc 'Update profiles stats'
  task update_profiles_stats: :environment do
    total = Profile.enabled.paraguayos.count
    processed = 0
    
    puts "Updating stats for #{total} enabled profiles..."
    puts "=" * 70
    
    Profile.enabled.paraguayos.order(followers: :desc).each do |profile|
      processed += 1
      puts "[#{processed}/#{total}] Updating stats for #{profile.username} - #{profile.followers} followers"
      
      begin
        profile.update_profile_stats
        puts "  ✓ Stats updated successfully"
      rescue StandardError => e
        puts "  ✗ Error: #{e.message}"
      end
    end
    
    puts "=" * 70
    puts "✓ Completed: #{processed} profiles processed"
  end
end
