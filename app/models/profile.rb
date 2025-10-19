# frozen_string_literal: true

class Profile < ApplicationRecord
  acts_as_taggable_on :tags
  has_one_attached :avatar
  serialize :data, Hash
  has_many :instagram_posts, dependent: :destroy

  enum :profile_type, %i[hombre mujer marca medio estatal memes programa]

  # As collaborator
  has_many :collaborated_collaborations,
           foreign_key: :collaborator_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborated, -> { paraguayos }, through: :collaborated_collaborations, source: :collaborated

  # Been collaborated
  has_many :collaborator_collaborations,
           foreign_key: :collaborated_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborators, -> { paraguayos }, through: :collaborator_collaborations, source: :collaborator

  validates :username, uniqueness: true

  after_create :update_profile

  scope :paraguayos, -> { where(country_string: 'Paraguay') }
  scope :otros, -> { where(country_string: 'Otros') }
  scope :no_country, -> { where(country_string: nil) }

  scope :has_uid, -> { where.not(uid: nil) }

  scope :no_profile_type, -> { where(profile_type: nil) }
  scope :has_profile_type, -> { where.not(profile_type: nil) }

  scope :micro, -> { where(followers: 5_000..) }
  scope :macro, -> { where(followers: 50_000..) }
  scope :tracked, -> { paraguayos.micro }
  scope :marcas, -> { paraguayos.where(profile_type: :marca) }
  scope :medios, -> { paraguayos.where(profile_type: :medio) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at
      data
      id
      updated_at
      username
      category_name
      is_private
      is_business_account
      followers
      biography
      country_string
      profile_type
    ]
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
      next if post.data.empty?
      next unless post.data['node']['coauthor_producers']

      post.data['node']['coauthor_producers'].each do |coauthor|
        collabs << coauthor['username']
      end
    end
    collabs.uniq!
    collabs.delete(username)
    collabs
  end

  def save_avatar_new
    url = profile_pic_url_hd || profile_pic_url
    return if url.blank? || username.blank?

    require 'open-uri'
    require 'fileutils'

    dir = Rails.public_path.join('images/profiles')
    FileUtils.mkdir_p(dir)

    ext = File.extname(URI.parse(url).path)
    ext = '.jpg' if ext.blank?
    filename = "#{username}#{ext}"
    filepath = dir.join(filename)

    begin
      File.binwrite(filepath, URI.open(url).read)
    rescue StandardError
      placeholder_url = 'https://placehold.co/500x500/000000/FFFFFF/jpg'
      File.binwrite(filepath, URI.open(placeholder_url).read)
    end
  end

  def save_avatar
    # next if avatar.attached?

    url = profile_pic_url_hd || profile_pic_url
    response = HTTParty.get(url)
    data = response.body
    filename = "#{username}.jpg"
    avatar.attach(io: StringIO.new(data), filename:)
  rescue StandardError => e
    puts e.message
  end

  def update_profile_stats
    stats_posts = instagram_posts.a_week_ago
    return if stats_posts.empty?

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
    data = InstagramServices::GetProfileData.call(username)
    return unless data.success?

    response = InstagramServices::UpdateProfileData.call(data.data)
    return unless response.success?

    update!(response.data)
    save_avatar
  end
end
