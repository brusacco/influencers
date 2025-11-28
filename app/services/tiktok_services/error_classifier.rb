# frozen_string_literal: true

module TiktokServices
  # Classifies TikTok API errors as permanent or temporary
  # Helps decide whether to disable profiles or retry operations
  # Similar to InstagramServices::ErrorClassifier
  class ErrorClassifier
    # Patterns that indicate permanent errors (profile doesn't exist, was deleted, etc.)
    PERMANENT_ERROR_PATTERNS = [
      /user not found/i,
      /profile not found/i,
      /invalid username/i,
      /account banned/i,
      /account deleted/i,
      /user does not exist/i,
      /username.*not.*found/i
    ].freeze

    # Patterns that indicate temporary errors (rate limits, timeouts, network issues)
    TEMPORARY_ERROR_PATTERNS = [
      /rate limit/i,
      /too many requests/i,
      /timeout/i,
      /network error/i,
      /temporary/i,
      /service unavailable/i,
      /503/i,
      /502/i,
      /504/i
    ].freeze

    # Classify an error message and return metadata about it
    # @param error_message [String] Error message from API or service
    # @return [Hash] Hash with :type, :user_message, and :action keys
    # @example
    #   TiktokServices::ErrorClassifier.describe("User not found")
    #   # => { type: :permanent, user_message: "...", action: :disable_profile }
    def self.describe(error_message)
      return default_unknown_error if error_message.blank?

      error_lower = error_message.to_s.downcase

      if permanent_error?(error_lower)
        {
          type: :permanent,
          user_message: 'Profile no longer exists or was deleted on TikTok',
          action: :disable_profile,
          retry: false
        }
      elsif temporary_error?(error_lower)
        {
          type: :temporary,
          user_message: 'Temporary error occurred, will retry later',
          action: :retry_later,
          retry: true
        }
      else
        default_unknown_error
      end
    end

    # Check if error indicates a permanent issue
    # @param error_lower [String] Lowercase error message
    # @return [Boolean]
    def self.permanent_error?(error_lower)
      PERMANENT_ERROR_PATTERNS.any? { |pattern| error_lower.match?(pattern) }
    end

    # Check if error indicates a temporary issue
    # @param error_lower [String] Lowercase error message
    # @return [Boolean]
    def self.temporary_error?(error_lower)
      TEMPORARY_ERROR_PATTERNS.any? { |pattern| error_lower.match?(pattern) }
    end

    # Default response for unknown errors
    # Conservative approach: treat as temporary to avoid disabling valid profiles
    # @return [Hash]
    def self.default_unknown_error
      {
        type: :unknown,
        user_message: 'Unknown error occurred',
        action: :log_and_continue,
        retry: true
      }
    end
  end
end

