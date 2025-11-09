# frozen_string_literal: true

module InstagramServices
  # Service to fetch Instagram profile data
  # @example
  #   result = InstagramServices::GetProfileData.call('username')
  #   if result.success?
  #     profile_data = result.data
  #   else
  #     error_message = result.error
  #   end
  class GetProfileData < Base
    def initialize(username)
      @username = username
    end

    def call
      data = fetch_instagram_data(@username)
      validate_response_structure!(data)
      handle_success(data)
    rescue InvalidUsernameError, APIError, TimeoutError, ParseError => e
      handle_error(e.message)
    rescue StandardError => e
      log_error("Unexpected error in GetProfileData: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      handle_error("Unexpected error: #{e.message}")
    end

    private

    # Validate that the response has the expected structure
    # @param data [Hash] Response data to validate
    # @raise [ParseError] if structure is invalid
    def validate_response_structure!(data)
      unless data.is_a?(Hash) && data.dig('data', 'user')
        raise ParseError, 'Invalid response structure: missing user data'
      end
    end
  end
end
