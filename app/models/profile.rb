# frozen_string_literal: true

class Profile < ApplicationRecord
  serialize :data, Hash
  has_many :instagram_posts, dependent: :destroy
  validates :username, uniqueness: true

  after_create :update_profile

  scope :paraguayos, -> { where(country_string: 'Paraguay') }
  scope :otros, -> { where(country_string: 'Otros') }
  scope :no_country, -> { where(country_string: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at data id updated_at username category_name is_private is_business_account followers biography country]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def related_brands
    related = []
    related << mentions
  end

  def mentions
    mentions = []
    instagram_posts.a_month_ago.each do |post|
      mentions << post.caption.scan(/(?:@(\w+{3,}))/).to_a if post.caption
    end
    mentions.flatten!
    mentions.map!(&:downcase)
    mentions.uniq!
    mentions.delete(username)
    mentions
  end

  def collaborations
    collabs = []
    instagram_posts.a_month_ago.each do |post|
      next unless post.data['node']['coauthor_producers']

      post.data['node']['coauthor_producers'].each do |coauthor|
        collabs << coauthor['username']
      end
    end
    collabs.uniq!
    collabs.delete(username)
    collabs
  end

  def save_avatar
    url = profile_pic_url_hd || profile_pic_url
    response = HTTParty.get(url)
    data = response.body
    update!(avatar: Base64.strict_encode64(data))
  end

  def update_profile_stats
    stats_posts = profile.instagram_posts.a_week_ago

    profile.total_likes_count = stats_posts.sum(:likes_count)
    profile.total_comments_count = stats_posts.sum(:comments_count)
    profile.total_video_view_count = stats_posts.sum(:video_view_count)
    profile.total_interactions_count = stats_posts.sum(:total_count)
    profile.total_posts = stats_posts.count
    profile.total_videos = stats_posts.where(media: 'GraphVideo').count
    profile.engagement_rate = (stats_posts.sum(:total_count) / Float(profile.followers) * 100).round
    profile.save!
  end

  def update_profile
    response = InstagramServices::GetProfileData.call(username)
    return unless response.success?

    update!(response.data) if response.success?

    response = InstagramServices::UpdateProfileData.call(data)
    return unless response.success?

    update!(response.data)
    save_avatar
  end
end
