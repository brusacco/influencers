# frozen_string_literal: true

module TiktokServices
  # Service to parse and transform raw TikTok profile data
  # Takes raw API response and extracts relevant profile fields
  # @example
  #   result = TiktokServices::UpdateProfileData.call(raw_data)
  #   if result.success?
  #     profile_attrs = result.data # Hash with profile attributes
  #   end
  class UpdateProfileData < Base
    # Required fields that must be present in the response
    REQUIRED_FIELDS = %w[
      userInfo
    ].freeze

    def initialize(data)
      @data = data
    end

    def call
      validate_data!
      
      user_info = extract_user_info
      validate_user_info_structure!(user_info)
      
      user = extract_user_data(user_info)
      stats = extract_stats_data(user_info)
      
      profile_attrs = build_profile_attributes(user, stats)
      
      handle_success(profile_attrs)
    rescue StandardError => e
      Rails.logger.error("[TiktokServices::UpdateProfileData] Error: #{e.message}")
      handle_error(e.message)
    end

    private

    # Validate that data exists and has expected structure
    # @raise [ArgumentError] if data is invalid
    def validate_data!
      raise ArgumentError, 'Data cannot be nil' if @data.nil?
      raise ArgumentError, 'Data must be a Hash' unless @data.is_a?(Hash)
      raise ArgumentError, 'Missing userInfo structure' unless @data['userInfo']
    end

    # Extract userInfo from response
    # @return [Hash] UserInfo data
    def extract_user_info
      @data['userInfo'] || {}
    end

    # Extract user data from userInfo
    # @param user_info [Hash] UserInfo data
    # @return [Hash] User data
    def extract_user_data(user_info)
      user_info['user'] || {}
    end

    # Extract stats data from userInfo
    # @param user_info [Hash] UserInfo data
    # @return [Hash] Stats data
    def extract_stats_data(user_info)
      user_info['stats'] || {}
    end

    # Validate that userInfo contains required fields
    # @param user_info [Hash] UserInfo data
    # @raise [ArgumentError] if required fields are missing
    def validate_user_info_structure!(user_info)
      unless user_info['user']
        raise ArgumentError, 'Missing user data in userInfo'
      end
    end

    # Build profile attributes hash from user and stats data
    # @param user [Hash] User data
    # @param stats [Hash] Stats data
    # @return [Hash] Profile attributes
    def build_profile_attributes(user, stats)
      {
        # Basic info
        username: user['uniqueId'],
        unique_id: user['uniqueId'],
        nickname: user['nickname'],
        signature: user['signature'],
        user_id: user['id'],
        sec_uid: user['secUid'],

        # Stats
        followers: safe_integer(stats['followerCount']),
        following: safe_integer(stats['followingCount']),
        hearts: safe_integer(stats['heartCount'] || stats['heart']),
        video_count: safe_integer(stats['videoCount']),
        digg_count: safe_integer(stats['diggCount']),
        friend_count: safe_integer(stats['friendCount']),

        # Status flags
        verified: user['verified'] || false,
        is_private: user['privateAccount'] || false,
        is_under_age_18: user['isUnderAge18'] || false,
        is_embed_banned: user['isEmbedBanned'] || false,
        commerce_user: user.dig('commerceUserInfo', 'commerceUser') || false,

        # Avatar URLs
        avatar_larger: user['avatarLarger'],
        avatar_medium: user['avatarMedium'],
        avatar_thumb: user['avatarThumb'],

        # Store full API response for debugging/archiving
        data: @data
      }
    end

  end
end

