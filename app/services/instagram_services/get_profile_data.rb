# frozen_string_literal: true

module InstagramServices
  # Compatibility adapter for consumers that still expect the legacy
  # { "data" => { "user" => ... } } profile payload.
  class GetProfileData < Base
    def initialize(username)
      @username = username
    end

    def call
      validate_username!(@username)

      result = ScrapeDoGraphqlProfileFetcher.call(@username)
      return handle_error(result.error) unless result.success?

      handle_success('data' => { 'user' => legacy_user(result.data) })
    rescue InvalidUsernameError => e
      handle_error(e.message)
    rescue StandardError => e
      log_error("Unexpected error in GetProfileData: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      handle_error("Unexpected error: #{e.message}")
    end

    private

    def legacy_user(profile)
      {
        'id' => profile['pk'] || profile['id'],
        'username' => profile['username'],
        'full_name' => profile['full_name'],
        'biography' => profile['biography'],
        'edge_followed_by' => { 'count' => profile['follower_count'] || 0 },
        'edge_follow' => { 'count' => profile['following_count'] || 0 },
        'profile_pic_url' => profile['profile_pic_url'],
        'profile_pic_url_hd' => profile['profile_pic_url_hd'],
        'is_private' => profile.fetch('is_private', false),
        'is_verified' => profile.fetch('is_verified', false),
        'is_embeds_disabled' => profile.fetch('is_embeds_disabled', false),
        'is_business_account' => profile.fetch('is_business_account', false),
        'is_professional_account' => profile.fetch('is_professional_account', false),
        'business_category_name' => profile['business_category_name'],
        'category_enum' => profile['category_enum'],
        'category_name' => profile['category_name'],
        'is_joined_recently' => profile.fetch('is_joined_recently', false)
      }
    end
  end
end
