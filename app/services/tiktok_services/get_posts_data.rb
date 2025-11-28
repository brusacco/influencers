# frozen_string_literal: true

module TiktokServices
  # Service to fetch TikTok posts/feed data from tikAPI.io
  # Uses /public/posts endpoint to retrieve feed posts for a user by secUid
  # Only requires API Key (no account key needed)
  # @example With profile object
  #   result = TiktokServices::GetPostsData.call(profile)
  # @example With secUid directly
  #   result = TiktokServices::GetPostsData.call(sec_uid: 'MS4wLjABAAAAsHntXC3s0AvxcecggxsoVa4eAiT8OVafVZ4OQXxy-9htpnUi0sOYSr0kGGD1Loud')
  # @example With username (will fetch secUid from profile first)
  #   result = TiktokServices::GetPostsData.call(username: 'angelybenitezz')
  #   if result.success?
  #     posts = result.data # Array of posts from itemList
  #   else
  #     error_message = result.error
  #   end
  class GetPostsData < Base
    def initialize(profile = nil, sec_uid: nil, username: nil, count: 30, cursor: nil)
      @profile = profile
      @sec_uid = sec_uid
      @username = username
      @count = [count.to_i, 30].min # Max 30 posts per request
      @cursor = cursor
    end

    def call
      # Resolve secUid from profile or username if needed
      sec_uid = resolve_sec_uid
      validate_sec_uid!(sec_uid)

      params = {
        secUid: sec_uid,
        count: @count
      }
      params[:cursor] = @cursor if @cursor.present?

      response = with_retry do
        make_request('/public/posts', params)
      end

      data = parse_response(response)
      validate_response_structure!(data)

      posts = extract_posts(data)
      log_api_call("Retrieved #{posts.count} posts for secUid: #{sec_uid}")

      handle_success(posts)
    rescue InvalidUsernameError, APIError, TimeoutError, ParseError => e
      handle_error(e.message)
    rescue StandardError => e
      log_error("Unexpected error in GetPostsData: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      handle_error("Unexpected error: #{e.message}")
    end

    private

    # Resolve secUid from profile, username, or use provided sec_uid
    # @return [String] secUid
    def resolve_sec_uid
      return @sec_uid if @sec_uid.present?

      if @profile.present?
        return @profile.sec_uid if @profile.respond_to?(:sec_uid) && @profile.sec_uid.present?
        return @profile.data.dig('userInfo', 'user', 'secUid') if @profile.respond_to?(:data)
      end

      if @username.present?
        # Fetch profile to get secUid
        profile_result = GetProfileData.call(username: @username)
        if profile_result.success?
          return profile_result.data.dig('userInfo', 'user', 'secUid')
        else
          raise InvalidUsernameError, "Could not fetch profile for username: #{@username}"
        end
      end

      raise ArgumentError, 'Must provide profile, sec_uid, or username'
    end

    # Validate secUid format
    # @param sec_uid [String] secUid to validate
    # @raise [ArgumentError] if sec_uid is invalid
    def validate_sec_uid!(sec_uid)
      if sec_uid.blank?
        raise ArgumentError, 'secUid cannot be blank'
      end

      # TikTok secUid format validation (starts with MS4wLjABAAA)
      unless sec_uid.match?(/\AMS4wLjABAAA/)
        raise ArgumentError, "Invalid secUid format: #{sec_uid}"
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

      # Check if itemList exists
      unless data.key?('itemList')
        error_message = data['message'] || 'Item list not found'
        raise APIError, "Item list not found: #{error_message}"
      end
    end

    # Extract posts from response
    # @param data [Hash] API response data
    # @return [Array] Array of posts from itemList
    def extract_posts(data)
      posts = data['itemList'] || []

      unless posts.is_a?(Array)
        log_error("itemList is not an array")
        return []
      end

      posts
    end
  end
end

