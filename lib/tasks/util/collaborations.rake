namespace :util do
  desc 'Generate collaborations'
  task collaborations: :environment do
    InstagramPost.a_month_ago.each do |post|
      next if InstagramCollaboration.exists?(instagram_post: post)
      next if post.data.empty?
      next if post.profile.followers < 50_000
      next unless post.data['node']['coauthor_producers']

      puts "Generating collaborations for #{post.shortcode} - #{post.profile.username}"
      post.data['node']['coauthor_producers'].each do |coauthor|
        next if coauthor['username'] == post.profile.username

        Profile.create!(username: coauthor['username']) unless Profile.exists?(username: coauthor['username'])

        collaborated_profile = Profile.find_by(username: coauthor['username'])

        InstagramCollaboration.create!(
          instagram_post: post,
          collaborator: post.profile,
          collaborated: collaborated_profile,
          created_at: post.posted_at
        )
      end
      puts '----------------------------------------------------'
    end
  end
end