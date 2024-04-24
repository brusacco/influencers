namespace :util do
  desc 'Add Related profiles to DB'
  task add_related_profiles: :environment do
    Profile.where(country_string: 'Paraguay', profile_type: :mujer, followers: 500_000..).find_each do |profile|
      puts "Addind profiles related to #{profile.username}"
      response = InstagramServices::GetProfileData.call(profile.username)
      next unless response.success?

      response = InstagramServices::GetRelatedProfiles.call(response.data)
      next unless response.success?

      response.data.each do |related_profile|
        Profile.find_or_create_by(username: related_profile) do |p|
          puts "Adding #{p.username} to DB"
        end
      end
    end
  end
end
