# frozen_string_literal: true

class TiktokProfile < ApplicationRecord
  serialize :data, Hash
  has_one_attached :avatar
  has_many :tiktok_posts, dependent: :destroy

  enum :profile_type, %i[hombre mujer marca medio estatal memes programa]

  validates :username, uniqueness: true, allow_nil: true
  validates :unique_id, uniqueness: true, allow_nil: true

  after_create :update_profile

  # Enabled/Disabled scopes
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Country scopes
  scope :paraguayos, -> { where(country_string: 'Paraguay') }
  scope :otros, -> { where(country_string: 'Otros') }
  scope :no_country, -> { where(country_string: nil) }

  # Follower scopes
  scope :micro, -> { where(followers: 10_000..) }
  scope :macro, -> { where(followers: 50_000..) }

  # Combined scopes - only enabled profiles
  scope :tracked, -> { enabled.paraguayos.micro }
  scope :marcas, -> { enabled.paraguayos.where(profile_type: :marca) }
  scope :medios, -> { enabled.paraguayos.where(profile_type: :medio) }

  # Custom setter for data field to handle both Hash and JSON string inputs
  # This matches how Profile model handles data, but adds support for JSON strings from forms
  def data=(value)
    case value
    when Hash
      super(value)
    when String
      # Handle empty strings or whitespace-only strings
      if value.blank? || value.strip.empty?
        super({})
      else
        # Parse JSON string
        parsed = JSON.parse(value.strip)
        super(parsed.is_a?(Hash) ? parsed : {})
      end
    else
      # Handle nil or any other type - default to empty hash
      super({})
    end
  rescue JSON::ParserError => e
    # If JSON parsing fails, log and default to empty hash
    Rails.logger.warn("Failed to parse data JSON: #{e.message}") if Rails.logger
    super({})
  end

  # Extract data from hash and populate database fields
  # This method should be called after fetching data from API
  def update_from_api_data(api_data)
    user_info = api_data.dig('userInfo') || {}
    user = user_info.dig('user') || {}
    stats = user_info.dig('stats') || {}

    self.username = user['uniqueId'] || username
    self.unique_id = user['uniqueId']
    self.nickname = user['nickname']
    self.signature = user['signature']
    self.user_id = user['id']
    self.sec_uid = user['secUid']

    # Stats
    self.followers = stats['followerCount'] || 0
    self.following = stats['followingCount'] || 0
    self.hearts = stats['heartCount'] || stats['heart'] || 0
    self.video_count = stats['videoCount'] || 0
    self.digg_count = stats['diggCount'] || 0
    self.friend_count = stats['friendCount'] || 0

    # Status flags
    self.verified = user['verified'] || false
    self.is_private = user['privateAccount'] || false
    self.is_under_age_18 = user['isUnderAge18'] || false
    self.is_embed_banned = user['isEmbedBanned'] || false
    self.commerce_user = user.dig('commerceUserInfo', 'commerceUser') || false

    # Avatar URLs
    self.avatar_larger = user['avatarLarger']
    self.avatar_medium = user['avatarMedium']
    self.avatar_thumb = user['avatarThumb']

    # Store full data
    self.data = api_data

    save!
    
    # Save avatar locally after updating data
    save_avatar
  end

  def self.ransackable_attributes(auth_object = nil)
    ["avatar_larger", "avatar_medium", "avatar_thumb", "commerce_user", "country_string", "created_at", "data", "digg_count", "enabled", "followers", "following", "friend_count", "hearts", "id", "is_embed_banned", "is_private", "is_under_age_18", "nickname", "profile_type", "query", "sec_uid", "signature", "unique_id", "updated_at", "user_id", "username", "verified", "video_count"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Helper methods that use database columns (with fallback to data hash)
  def display_username
    username || unique_id
  end

  def display_nickname
    nickname.presence || display_username
  end

  def follower_count
    followers
  end

  def following_count
    following
  end

  def heart_count
    hearts
  end

  def private_account
    is_private
  end

  # Save avatar locally using ActiveStorage
  def save_avatar
    return if avatar.attached?
    url = avatar_larger
    return if url.blank? || username.blank?

    begin
      response = HTTParty.get(url)
      data = response.body
      filename = "#{username || unique_id}.jpg"
      avatar.attach(io: StringIO.new(data), filename:)
    rescue StandardError => e
      Rails.logger.warn("Failed to save TikTok avatar for #{username}: #{e.message}") if Rails.logger
    end
  end

  # Update profile from TikTok API
  def update_profile
    return if username.blank?

    result = TiktokServices::GetProfileData.call(username: username)
    return unless result.success?

    update_from_api_data(result.data)
  end

  # Fetch and save posts from TikTok API
  # @return [Hash] Summary hash with counts
  def update_posts
    return { success: false, error: 'Username is required' } if username.blank?

    result = TiktokServices::GetPostsData.call(self)
    return { success: false, error: result.error } unless result.success?

    posts_updated = 0
    posts_created = 0
    errors = []

    result.data.each do |post_data|
      post_id = post_data['id']
      next if post_id.blank?

      post = tiktok_posts.find_or_initialize_by(tiktok_post_id: post_id)
      was_new = post.new_record?

      begin
        post.update_from_api_data(post_data)
        posts_updated += 1
        posts_created += 1 if was_new
      rescue StandardError => e
        errors << "Post #{post_id}: #{e.message}"
      end
    end

    {
      success: true,
      posts_updated: posts_updated,
      posts_created: posts_created,
      errors: errors
    }
  end
end

