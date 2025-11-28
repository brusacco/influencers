# frozen_string_literal: true

module TiktokServices
  # Base service class for TikTok API interactions
  # Provides common functionality for all TikTok services:
  # - API request handling
  # - Error management with specific exception types
  # - Logging
  # - Validation
  class Base < ApplicationService
    class InvalidUsernameError < StandardError; end
    class APIError < StandardError; end
    class TimeoutError < StandardError; end
    class ParseError < StandardError; end

    private

    # Make HTTP request to TikTok API
    # @param endpoint [String] API endpoint path (e.g., '/user/info')
    # @param params [Hash] Query parameters (optional)
    # @return [HTTParty::Response] Response object
    # @raise [APIError] if response status is not 200
    def make_request(endpoint, params = {})
      url = "#{TikTokConfig::API_BASE_URL}#{endpoint}"
      headers = build_headers

      log_api_call("Making request to: #{url}")

      response = HTTParty.get(
        url,
        headers: headers,
        query: params,
        timeout: TikTokConfig::API_TIMEOUT
      )

      # Check for HTTP errors
      unless response.success?
        error_message = begin
          parsed = JSON.parse(response.body)
          parsed['message'] || parsed['error'] || response.body[0..200]
        rescue
          response.body[0..200]
        end

        case response.code
        when 404
          raise APIError, "Resource not found (404): #{error_message}"
        when 401
          raise APIError, "Unauthorized (401) - Check API keys: #{error_message}"
        when 400
          raise APIError, "Bad request (400): #{error_message}"
        when 429
          raise APIError, "Rate limit exceeded (429): #{error_message}"
        when 500..599
          raise APIError, "TikTok API server error (#{response.code}): #{error_message}"
        else
          raise APIError, "HTTP error #{response.code}: #{error_message}"
        end
      end

      response
    rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout => e
      log_error("Timeout error: #{e.class} - #{e.message}")
      raise TimeoutError, "TikTok API timeout: #{e.message}"
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
      log_error("Network error: #{e.class} - #{e.message}")
      raise APIError, "Network error: #{e.message}"
    end

    # Build headers for TikTok API requests
    # @return [Hash] Headers hash
    def build_headers
      {
        'X-API-KEY' => TikTokConfig::API_KEY,
        'accept' => 'application/json'
      }
    end

    # Parse JSON response
    # @param response [HTTParty::Response] HTTP response
    # @return [Hash] Parsed JSON data
    # @raise [ParseError] if JSON parsing fails
    def parse_response(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      log_error("JSON parse error: #{e.message}")
      raise ParseError, "Invalid JSON response: #{e.message}"
    end

    # Retry logic for temporary network errors
    # @param max_retries [Integer] Maximum number of retries
    # @yield Block to execute with retry logic
    # @return [Object] Result of the block
    def with_retry(max_retries: TikTokConfig::MAX_RETRIES)
      attempt = 0

      begin
        attempt += 1
        yield
      rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
        if attempt <= max_retries
          delay = 2 ** attempt # Exponential backoff: 2s, 4s, 8s
          log_error("Attempt #{attempt}/#{max_retries} failed: #{e.class} - Retrying in #{delay}s...")
          sleep delay
          retry
        else
          log_error("All #{max_retries} attempts failed: #{e.class} - #{e.message}")
          raise # Re-raise the exception after all retries are exhausted
        end
      end
    end

    # Log API call if logging is enabled
    # @param message [String] Log message
    def log_api_call(message)
      return unless TikTokConfig::LOG_API_CALLS

      Rails.logger.info("[TikTokAPI] #{message}")
    end

    # Log error message
    # @param message [String] Error message
    def log_error(message)
      Rails.logger.error("[TikTokAPI] #{message}")
    end

    # Validate that data hash contains required keys
    # @param data [Hash] Data hash to validate
    # @param keys [Array<String>] Required keys (can be dot-separated for nested keys)
    # @raise [ArgumentError] if required keys are missing
    def validate_data_structure!(data, *keys)
      return if data.nil?

      keys.each do |key|
        next if data.dig(*key.split('.'))

        raise ArgumentError, "Missing required data key: #{key}"
      end
    end

    # Safe dig into nested hash structure
    # @param hash [Hash] Hash to dig into
    # @param keys [Array] Keys to dig
    # @param default [Object] Default value if key not found
    # @return [Object] Value or default
    def safe_dig(hash, *keys, default: nil)
      hash.dig(*keys) || default
    rescue StandardError
      default
    end
  end
end

