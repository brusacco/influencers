# frozen_string_literal: true

module InstagramServices
  # Service to classify Instagram API errors into categories
  # This helps determine whether a profile should be disabled or just retried
  #
  # @example
  #   error_type = InstagramServices::ErrorClassifier.classify(error_message)
  #   case error_type
  #   when :permanent
  #     profile.update!(enabled: false)
  #   when :temporary
  #     # Retry or log, but don't disable
  #   end
  class ErrorClassifier
    # Errors that indicate a profile no longer exists or is permanently unavailable
    PERMANENT_ERROR_PATTERNS = [
      '404',
      'not found',
      'user does not exist',
      "doesn't exist",
      'deleted',
      'invalid response structure: missing user data',
      'user not found on instagram'
    ].freeze

    # Errors that are temporary and should not trigger profile disabling
    TEMPORARY_ERROR_PATTERNS = [
      'timeout',
      'network error',
      'connection',
      'rate limit',
      '429',
      'attempts failed',
      'execution expired',
      'connection refused',
      'host unreachable',
      'socket error'
    ].freeze

    # Check if an error indicates a permanent profile issue
    # @param error_message [String, Exception] Error message or exception
    # @return [Boolean] true if error is permanent
    def self.permanent?(error_message)
      message = normalize_message(error_message)
      
      PERMANENT_ERROR_PATTERNS.any? do |pattern|
        message.include?(pattern)
      end
    end

    # Check if an error indicates a temporary network/API issue
    # @param error_message [String, Exception] Error message or exception
    # @return [Boolean] true if error is temporary
    def self.temporary?(error_message)
      message = normalize_message(error_message)
      
      TEMPORARY_ERROR_PATTERNS.any? do |pattern|
        message.include?(pattern)
      end || message.include?('all') && message.include?('attempts failed')
    end

    # Classify error into category
    # @param error_message [String, Exception] Error message or exception
    # @return [Symbol] :permanent, :temporary, or :unknown
    def self.classify(error_message)
      return :permanent if permanent?(error_message)
      return :temporary if temporary?(error_message)
      
      :unknown
    end

    # Get user-friendly description of error type
    # @param error_message [String, Exception] Error message or exception
    # @return [Hash] error type and description
    def self.describe(error_message)
      type = classify(error_message)
      
      case type
      when :permanent
        {
          type: :permanent,
          action: 'disable_profile',
          description: 'Profile no longer exists on Instagram',
          user_message: 'Profile not found on Instagram - DISABLED'
        }
      when :temporary
        {
          type: :temporary,
          action: 'retry_later',
          description: 'Temporary network or API issue',
          user_message: 'Temporary error (not disabling)'
        }
      when :unknown
        {
          type: :unknown,
          action: 'log_and_monitor',
          description: 'Unknown error type - investigate',
          user_message: 'Unknown error (not disabling)'
        }
      end
    end

    private

    # Normalize error message for comparison
    # @param error_message [String, Exception] Error message or exception
    # @return [String] normalized lowercase message
    def self.normalize_message(error_message)
      case error_message
      when Exception
        error_message.message.to_s.downcase
      when String
        error_message.to_s.downcase
      else
        error_message.to_s.downcase
      end
    end
  end
end

