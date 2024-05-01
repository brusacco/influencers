namespace :util do
  desc 'Update MIssing Avatars'
  task update_missing_avatars: :environment do
    Profile.find_each do |profile|
      next if profile.avatar.attached?

      puts "Updating #{profile.username} avatar"
      profile.update_profile
    end
  end
end
