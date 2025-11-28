# frozen_string_literal: true

module TiktokServices
  # Service to fetch TikTok profile data from tikAPI.io
  # Queries public profile data by username
  # @example Query by username
  #   result = TiktokServices::GetProfileData.call(username: 'angelybenitezz')
  #   if result.success?
  #     profile_data = result.data
  #   else
  #     error_message = result.error
  #   end
  class GetProfileData < Base
    def initialize(username:)
      @username = username
    end

    def call
      validate_username!(@username)
      response = with_retry do
        make_request('/public/check', { username: @username })
      end

      data = parse_response(response)
      validate_response_structure!(data)
      handle_success(data)
    rescue InvalidUsernameError, APIError, TimeoutError, ParseError => e
      handle_error(e.message)
    rescue StandardError => e
      log_error("Unexpected error in GetProfileData: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      handle_error("Unexpected error: #{e.message}")
    end

    private

    # Validate TikTok username format
    # @param username [String] Username to validate
    # @raise [InvalidUsernameError] if username is invalid
    def validate_username!(username)
      if username.blank?
        raise InvalidUsernameError, 'Username cannot be blank'
      end

      # TikTok usernames can contain letters, numbers, underscores, and dots
      unless username.match?(/\A[\w.]+\z/)
        raise InvalidUsernameError, "Invalid username format: #{username}"
      end

      if username.length > 30
        raise InvalidUsernameError, "Username too long: #{username}"
      end
    end

    # Validate that the response has the expected structure
    # @param data [Hash] Response data to validate
    # @raise [ParseError] if structure is invalid
    def validate_response_structure!(data)
      unless data.is_a?(Hash)
        raise ParseError, 'Invalid response structure: not a hash'
      end

      # Check if status indicates success
      status = data['status'] || data['statusCode']
      if status != 'success' && status != 0
        error_message = data['message'] || 'Unknown error'
        raise APIError, "TikTok API error: #{error_message}"
      end

      # Check if userInfo exists
      user_info = data.dig('userInfo')
      if user_info.nil?
        error_message = data['message'] || 'User info not found'
        raise APIError, "User info not found: #{error_message}"
      end

      # Check if user data exists within userInfo
      user_data = user_info.dig('user')
      if user_data.nil?
        raise ParseError, 'Invalid response structure: missing user data'
      end
    end
  end
end

