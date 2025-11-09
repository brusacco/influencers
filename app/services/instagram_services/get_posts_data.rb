# frozen_string_literal: true

module InstagramServices
  # Service to fetch Instagram posts data for a profile
  # Retrieves both regular posts and video timeline (reels)
  # @example
  #   result = InstagramServices::GetPostsData.call(profile)
  #   if result.success?
  #     posts = result.data # Array of posts
  #   else
  #     error_message = result.error
  #   end
  class GetPostsData < Base
    def initialize(profile)
      @profile = profile
    end

    def call
      validate_profile!
      
      data = fetch_instagram_data(@profile.username)
      validate_response_structure!(data)
      
      posts = extract_posts(data)
      videos = extract_videos(data)
      
      combined_posts = posts + videos
      log_api_call("Retrieved #{combined_posts.count} posts for @#{@profile.username}")
      
      handle_success(combined_posts)
    rescue InvalidUsernameError, APIError, TimeoutError, ParseError => e
      handle_error(e.message)
    rescue StandardError => e
      log_error("Unexpected error in GetPostsData: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      handle_error("Unexpected error: #{e.message}")
    end

    private

    # Validate that profile exists and has username
    # @raise [ArgumentError] if profile is invalid
    def validate_profile!
      raise ArgumentError, 'Profile cannot be nil' if @profile.nil?
      raise ArgumentError, 'Profile must have a username' if @profile.username.blank?
    end

    # Validate response structure
    # @param data [Hash] Response data
    # @raise [ParseError] if structure is invalid
    def validate_response_structure!(data)
      unless data.is_a?(Hash) && data.dig('data', 'user')
        raise ParseError, 'Invalid response structure: missing user data'
      end
    end

    # Extract regular posts from response
    # @param data [Hash] API response data
    # @return [Array] Array of post edges
    def extract_posts(data)
      posts = safe_dig(data, 'data', 'user', 'edge_owner_to_timeline_media', 'edges', default: [])
      
      unless posts.is_a?(Array)
        log_error("Posts is not an array for @#{@profile.username}")
        return []
      end
      
      posts
    end

    # Extract videos (reels) from response
    # @param data [Hash] API response data
    # @return [Array] Array of video edges
    def extract_videos(data)
      videos = safe_dig(data, 'data', 'user', 'edge_felix_video_timeline', 'edges', default: [])
      
      unless videos.is_a?(Array)
        log_error("Videos is not an array for @#{@profile.username}")
        return []
      end
      
      videos
    end
  end
end
