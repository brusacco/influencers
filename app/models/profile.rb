# frozen_string_literal: true

class Profile < ApplicationRecord
  has_one_attached :avatar
  serialize :data, Hash
  has_many :instagram_posts, dependent: :destroy

  enum :profile_type, [ :hombre, :mujer, :marca, :medio, :estatal ]

  # As collaborator
  has_many :collaborated_collaborations,
           foreign_key: :collaborator_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborated, through: :collaborated_collaborations, source: :collaborated

  # As collaborated
  has_many :collaborator_collaborations,
           foreign_key: :collaborated_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborators, through: :collaborator_collaborations, source: :collaborator

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
    related << collaborations_hash
    related.flatten!
    related.uniq!
    related
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

  def collaborations_hash
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

    filename = "#{username}.jpg"
    avatar.attach(io: StringIO.new(data), filename: filename)
  end

  def update_profile_stats
    stats_posts = instagram_posts.a_week_ago

    self.total_likes_count = stats_posts.sum(:likes_count)
    self.total_comments_count = stats_posts.sum(:comments_count)
    self.total_video_view_count = stats_posts.sum(:video_view_count)
    self.total_interactions_count = stats_posts.sum(:total_count)
    self.total_posts = stats_posts.count
    self.total_videos = stats_posts.where(media: 'GraphVideo').count
    self.engagement_rate = (stats_posts.sum(:total_count) / Float(followers) * 100).round
    save!
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
