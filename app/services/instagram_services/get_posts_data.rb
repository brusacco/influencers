# frozen_string_literal: true

module InstagramServices
  # Compatibility wrapper around the public Scrape.do GraphQL post-grid fetcher.
  # It returns GraphQL media nodes, not the retired web-profile edge payload.
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

      result = ScrapeDoGraphqlPostsFetcher.call(@profile.username)
      return handle_error(result.error) unless result.success?

      log_api_call("Retrieved #{result.data.count} posts for @#{@profile.username}")
      handle_success(result.data)
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

  end
end
