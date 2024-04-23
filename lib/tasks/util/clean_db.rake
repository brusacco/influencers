namespace :util do
  desc 'Generate collaborations'
  task clean_db: :environment do
    Profile.where.not(country_string: 'Paraguay').find_each do |profile|
      puts "Cleaning #{profile.username} posts"
      profile.instagram_posts.find_each do |post|
        puts post.shortcode
        post.destroy!
      end
    end
  end
end
