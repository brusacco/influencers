# frozen_string_literal: true

class Profile < ApplicationRecord
  acts_as_taggable_on :tags
  has_many :instagram_profile_stats, dependent: :destroy
  has_one_attached :avatar
  serialize :data, Hash
  has_many :instagram_posts, dependent: :destroy

  enum :profile_type, %i[hombre mujer marca medio estatal memes programa]

  # As collaborator
  has_many :collaborated_collaborations,
           foreign_key: :collaborator_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborated,
           lambda {
             where(profiles: { country_string: 'Paraguay' })
           },
           through: :collaborated_collaborations,
           source: :collaborated

  # Been collaborated
  has_many :collaborator_collaborations,
           foreign_key: :collaborated_id,
           class_name: 'InstagramCollaboration',
           dependent: :destroy
  has_many :collaborators,
           lambda {
             where(profiles: { country_string: 'Paraguay' })
           },
           through: :collaborator_collaborations,
           source: :collaborator

  validates :username, uniqueness: true

  after_create :update_profile

  scope :paraguayos, -> { where(country_string: 'Paraguay') }
  scope :otros, -> { where(country_string: 'Otros') }
  scope :no_country, -> { where(country_string: nil) }

  scope :has_uid, -> { where.not(uid: nil) }

  scope :no_profile_type, -> { where(profile_type: nil) }
  scope :has_profile_type, -> { where.not(profile_type: nil) }

  scope :micro, -> { where(followers: 10_000..) }
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
    self.total_interactions_count = total_likes_count + total_comments_count + total_video_view_count
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

  # Business Logic Methods for Metrics

  # Calculate median interactions per post
  # @return [Integer] median interactions count
  def median_interactions
    return 0 if total_posts.zero?

    total_interactions_count / total_posts
  end

  # Calculate median video views per video
  # @return [Integer] median video views count
  def median_video_views
    return 0 if total_videos.zero?

    total_video_view_count / total_videos
  end

  # Calculate estimated reach using hybrid method
  # Combines follower-based and interaction-based calculations
  # @return [Integer] estimated reach (unique accounts reached)
  def estimated_reach
    return 0 if followers.zero? || total_posts.zero?

    # Método 1: Basado en followers
    follower_based_reach = calculate_follower_based_reach

    # Método 2: Basado en interacciones
    interaction_based_reach = calculate_interaction_based_reach

    # Promedio ponderado (60% followers, 40% interactions)
    weighted_reach = (follower_based_reach * 0.6) + (interaction_based_reach * 0.4)

    # Cap máximo: nunca más del 50% de followers
    max_reach = followers * 0.5

    [weighted_reach, max_reach].min.round
  end

  # Calculate estimated reach as percentage of followers
  # @return [Float] reach percentage (0-100)
  def estimated_reach_percentage
    return 0.0 if followers.zero?

    (estimated_reach.to_f / followers * 100).round(2)
  end

  # Find related profiles based on tags, profile_type, or interactions
  # @param limit [Integer] maximum number of profiles to return
  # @return [ActiveRecord::Relation] collection of related profiles
  def related_profiles(limit: RELATED_PROFILES_LIMIT)
    if tags.any?
      # Find profiles with similar tags
      self.class.paraguayos
          .with_attached_avatar
          .tagged_with(tags.map(&:name), any: true)
          .where.not(id: id)
          .order(followers: :desc)
          .limit(limit)
    elsif profile_type
      # Find profiles in same category
      self.class.paraguayos
          .with_attached_avatar
          .where(profile_type: profile_type)
          .where.not(id: id)
          .order(followers: :desc)
          .limit(limit)
    else
      # Find profiles by interactions
      self.class.paraguayos
          .with_attached_avatar
          .where.not(id: id)
          .order(total_interactions_count: :desc)
          .limit(limit)
    end
  end

  # Get profiles mentioned in recent posts
  # @param limit [Integer] maximum number of profiles to return
  # @return [ActiveRecord::Relation] collection of mentioned profiles
  def mentions_profiles(limit: MENTIONS_LIMIT)
    self.class.where(username: mentions).limit(limit)
  end

  # Get recent posts
  # @param limit [Integer] maximum number of posts to return
  # @return [ActiveRecord::Relation] collection of recent posts
  def recent_posts(limit: RECENT_POSTS_LIMIT)
    instagram_posts.order(posted_at: :desc).limit(limit)
  end

  # Get recent collaborations
  # @param limit [Integer] maximum number of collaborations to return
  # @return [ActiveRecord::Relation] collection of recent collaborations
  def recent_collaborations(limit: COLLABORATIONS_LIMIT)
    collaborated_collaborations
      .includes(:instagram_post)
      .order(posted_at: :desc)
      .limit(limit)
  end

  private

  # Calculate reach based on follower count and adjustments
  # @return [Float] follower-based reach estimation
  def calculate_follower_based_reach
    base_reach_percentage = 15.0

    reach = followers * (base_reach_percentage / 100.0)
    reach *= engagement_multiplier
    reach *= content_type_multiplier
    reach *= account_quality_multiplier

    reach
  end

  # Calculate reach based on actual interaction data
  # @return [Float] interaction-based reach estimation
  def calculate_interaction_based_reach
    return 0 if total_posts.zero?

    avg_interactions = median_interactions

    # Ratio de engagement típico: 10-12% de quienes ven el post interactúan
    interaction_rate = has_high_video_ratio? ? 0.12 : 0.10

    # Alcance estimado por post
    avg_interactions / interaction_rate
  end

  # Calculate multiplier based on engagement rate
  # @return [Float] engagement multiplier (0.5 - 2.0)
  def engagement_multiplier
    benchmark = 3.0
    actual = engagement_rate.to_f

    if actual >= benchmark
      # Alto engagement: multiplier entre 1.0 y 2.0
      [1.0 + ((actual - benchmark) / 10.0), 2.0].min
    else
      # Bajo engagement: multiplier entre 0.5 y 1.0
      [0.5 + (actual / benchmark) * 0.5, 1.0].min
    end
  end

  # Calculate multiplier based on content type (video ratio)
  # @return [Float] content multiplier (1.0 - 1.5)
  def content_type_multiplier
    return 1.0 if total_posts.zero?

    video_ratio = total_videos.to_f / total_posts

    # Instagram favorece video content
    # 0% videos = 1.0x, 50% videos = 1.25x, 100% videos = 1.5x
    1.0 + (video_ratio * 0.5)
  end

  # Calculate multiplier based on account type and verification
  # @return [Float] account quality multiplier (0.9 - 1.6+)
  def account_quality_multiplier
    multiplier = 1.0

    # Cuentas verificadas tienen ~20% más alcance
    multiplier *= 1.2 if is_verified

    # Cuentas business tienen mejor distribución
    multiplier *= 1.1 if is_business_account

    # Ajuste por tipo de perfil
    case profile_type
    when 'medio', 'estatal'
      multiplier *= 1.15 # Contenido informativo tiene más alcance
    when 'memes'
      multiplier *= 1.3  # Contenido viral tiene mucho más alcance
    when 'marca'
      multiplier *= 0.9  # Contenido comercial tiene menos alcance orgánico
    end

    multiplier
  end

  # Check if profile has high video content ratio
  # @return [Boolean] true if more than 40% of posts are videos
  def has_high_video_ratio?
    return false if total_posts.zero?

    (total_videos.to_f / total_posts) > 0.4
  end
end
