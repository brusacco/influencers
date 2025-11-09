# frozen_string_literal: true

module InstagramServices
  # Service to parse and transform raw Instagram profile data
  # Takes raw API response and extracts relevant profile fields
  # @example
  #   result = InstagramServices::UpdateProfileData.call(raw_data)
  #   if result.success?
  #     profile_attrs = result.data # Hash with profile attributes
  #   end
  class UpdateProfileData < ApplicationService
    # Required fields that must be present in the response
    REQUIRED_FIELDS = %w[
      edge_followed_by
      edge_follow
      profile_pic_url
      is_private
      is_verified
      full_name
      biography
      is_embeds_disabled
      id
    ].freeze

    # Optional fields with default values
    OPTIONAL_FIELDS = {
      profile_pic_url_hd: nil,
      is_business_account: false,
      is_professional_account: false,
      business_category_name: nil,
      category_enum: nil,
      category_name: nil,
      is_joined_recently: false
    }.freeze

    def initialize(data)
      @data = data
    end

    def call
      validate_data!
      
      user = extract_user_data
      validate_user_structure!(user)
      
      profile_attrs = build_profile_attributes(user)
      
      handle_success(profile_attrs)
    rescue ArgumentError, StandardError => e
      Rails.logger.error("[UpdateProfileData] Error: #{e.message}")
      handle_error(e.message)
    end

    private

    # Validate that data exists and has expected structure
    # @raise [ArgumentError] if data is invalid
    def validate_data!
      raise ArgumentError, 'Data cannot be nil' if @data.nil?
      raise ArgumentError, 'Data must be a Hash' unless @data.is_a?(Hash)
      raise ArgumentError, 'Missing data.user structure' unless @data.dig('data', 'user')
    end

    # Extract user data from response
    # @return [Hash] User data
    def extract_user_data
      @data['data']['user']
    end

    # Validate that user data contains required fields
    # @param user [Hash] User data
    # @raise [ArgumentError] if required fields are missing
    def validate_user_structure!(user)
      missing_fields = REQUIRED_FIELDS.reject { |field| user.key?(field) }
      
      return if missing_fields.empty?
      
      raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
    end

    # Build profile attributes hash from user data
    # @param user [Hash] User data
    # @return [Hash] Profile attributes
    def build_profile_attributes(user)
      {
        # Counters
        followers: safe_count(user, 'edge_followed_by'),
        following: safe_count(user, 'edge_follow'),
        
        # Profile images
        profile_pic_url: user['profile_pic_url'],
        profile_pic_url_hd: user['profile_pic_url_hd'] || OPTIONAL_FIELDS[:profile_pic_url_hd],
        
        # Account type
        is_business_account: user['is_business_account'] || OPTIONAL_FIELDS[:is_business_account],
        is_professional_account: user['is_professional_account'] || OPTIONAL_FIELDS[:is_professional_account],
        
        # Categories
        business_category_name: user['business_category_name'] || OPTIONAL_FIELDS[:business_category_name],
        category_enum: user['category_enum'] || OPTIONAL_FIELDS[:category_enum],
        category_name: user['category_name'] || OPTIONAL_FIELDS[:category_name],
        
        # Status flags
        is_private: user['is_private'],
        is_verified: user['is_verified'],
        is_joined_recently: user['is_joined_recently'] || OPTIONAL_FIELDS[:is_joined_recently],
        is_embeds_disabled: user['is_embeds_disabled'],
        
        # Profile info
        full_name: user['full_name'],
        biography: user['biography'],
        
        # Instagram ID
        uid: user['id']
      }
    end

    # Safely extract count from edge structure
    # @param user [Hash] User data
    # @param edge_key [String] Edge key to extract
    # @return [Integer] Count value or 0
    def safe_count(user, edge_key)
      user.dig(edge_key, 'count') || 0
    end
  end
end
