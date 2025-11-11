# frozen_string_literal: true

namespace :instagram do
  desc 'Check if a profile exists on Instagram and disable if not found'
  task :check_profile, [:username] => :environment do |_t, args|
    unless args[:username]
      puts "Usage: rake instagram:check_profile[username]"
      puts "Example: rake instagram:check_profile[__memes__py]"
      exit
    end
    
    username = args[:username]
    profile = Profile.find_by(username: username)
    
    unless profile
      puts "❌ Profile '#{username}' not found in database"
      exit
    end
    
    puts "=" * 70
    puts "CHECKING PROFILE: @#{username}"
    puts "=" * 70
    puts ""
    puts "Database Info:"
    puts "  - ID: #{profile.id}"
    puts "  - UID: #{profile.uid}"
    puts "  - Enabled: #{profile.enabled ? '✓ Yes' : '✗ No'}"
    puts "  - Followers: #{profile.followers&.to_s&.reverse&.gsub(/(\d{3})(?=\d)/, '\\1.')&.reverse || 'N/A'}"
    puts "  - Country: #{profile.country_string}"
    puts ""
    puts "Checking Instagram API..."
    puts "-" * 70
    
    result = InstagramServices::GetProfileData.call(username)
    
    if result.success?
      puts "✓ PROFILE EXISTS ON INSTAGRAM"
      puts ""
      data = result.data
      user_data = data.dig('data', 'user')
      
      if user_data
        puts "Instagram Data:"
        puts "  - Username: #{user_data['username']}"
        puts "  - Full Name: #{user_data['full_name']}"
        puts "  - Followers: #{user_data.dig('edge_followed_by', 'count')&.to_s&.reverse&.gsub(/(\d{3})(?=\d)/, '\\1.')&.reverse || 'N/A'}"
        puts "  - Is Private: #{user_data['is_private'] ? 'Yes' : 'No'}"
        puts "  - Is Verified: #{user_data['is_verified'] ? 'Yes' : 'No'}"
        puts ""
        
        if profile.enabled
          puts "✓ Profile is enabled and accessible"
        else
          puts "⚠ Profile exists on IG but is disabled in database"
          puts "  Run: Profile.find(#{profile.id}).update!(enabled: true) to re-enable"
        end
      end
    else
      puts "✗ PROFILE NOT FOUND ON INSTAGRAM"
      puts ""
      puts "Error: #{result.error}"
      puts ""
      
      if profile.enabled
        puts "⚠ Profile is currently enabled but doesn't exist on Instagram"
        puts ""
        print "Disable this profile? [y/N]: "
        response = STDIN.gets.chomp.downcase
        
        if response == 'y' || response == 'yes'
          profile.update!(enabled: false)
          puts "✓ Profile has been disabled"
        else
          puts "Profile remains enabled (no changes made)"
        end
      else
        puts "✓ Profile is already disabled"
      end
    end
    
    puts ""
    puts "=" * 70
  end
end

