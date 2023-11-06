# frozen_string_literal: true

namespace :util do
  desc 'Migrate old Base64 encoded images to new format'
  task migrate_images: :environment do
    profile = Profile.find(3082)
    # InstagramPost.find_each do |post|
    profile.instagram_posts.find_each do |post|
      if post.temp_image.present?
        puts post.shortcode
        decoded_image = Base64.strict_decode64(post.temp_image)
        post.image.attach(io: StringIO.new(decoded_image), filename: "#{post.shortcode}.jpg")
      end
    end
  end

  task migrate_avatars: :environment do
    Profile.find_each do |profile|
      next if profile.avatar.attached?

      if profile.temp_image.present?
        puts profile.username
        decoded_image = Base64.strict_decode64(profile.temp_image)
        profile.avatar.attach(io: StringIO.new(decoded_image), filename: "#{profile.username}.jpg")
      end
    rescue Exception => e
      profile.update!(data: nil)
      puts e.message
      next
    end
  end
end
