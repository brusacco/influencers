namespace :util do
  desc 'Update MIssing Avatars'
  task update_missing_avatars: :environment do
    Parallel.each(Profile.order(followers: :desc), in_processes: 10) do |profile|
      next if profile.avatar.attached?

      puts "Updating #{profile.username} avatar"
      profile.update_profile
    end
  end
end
