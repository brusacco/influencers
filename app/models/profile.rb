# frozen_string_literal: true

class Profile < ApplicationRecord
  serialize :data, Hash
  has_many :instagram_posts, dependent: :destroy
  validates :username, uniqueness: true

  after_create :update_profile

  scope :paraguayos, -> { where(country_string: 'Paraguay') }
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

  def update_profile
    response = InstagramServices::GetProfileData.call(username)
    return unless response.success?

    update!(response.data) if response.success?

    response = InstagramServices::UpdateProfileData.call(data)
    return unless response.success?

    update!(response.data)
    save_avatar if avatar.nil?
  end
end