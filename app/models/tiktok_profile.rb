# frozen_string_literal: true

class TiktokProfile < ApplicationRecord
  include JsonDataSetter
  include ImageDownloader
  include ReachCalculator

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


  # Extract data from hash and populate database fields
  # Uses UpdateProfileData service to transform raw data
  # This method is kept for backward compatibility but now uses the service layer
  # @param api_data [Hash] Raw API response data
  def update_from_api_data(api_data)
    # Use UpdateProfileData service to transform raw data
    result = TiktokServices::UpdateProfileData.call(api_data)
    return unless result.success?

    # Update model with transformed attributes
    update!(result.data)
    
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
    return if avatar_larger.blank? || username.blank?

    filename = "#{username || unique_id}.jpg"
    download_and_attach_image(
      avatar_larger,
      :avatar,
      filename,
      placeholder_url: nil
    )
  end

  # Update profile from TikTok API
  def update_profile
    return if username.blank?

    # Step 1: Get raw data from API
    result = TiktokServices::GetProfileData.call(username: username)
    return unless result.success?

    # Step 2: Transform raw data to profile attributes
    update_result = TiktokServices::UpdateProfileData.call(result.data)
    return unless update_result.success?

    # Step 3: Update model with transformed attributes
    update!(update_result.data)
    
    # Step 4: Save avatar locally
    save_avatar
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

