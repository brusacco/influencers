# frozen_string_literal: true

module InstagramServices
  # Base service class for Instagram API interactions
  # Provides common functionality for all Instagram services:
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

    # Fetch Instagram profile data via Scrape.do proxy with retry logic
    # @param username [String] Instagram username
    # @return [Hash] Parsed JSON response
    # @raise [InvalidUsernameError] if username is invalid
    # @raise [TimeoutError] if request times out after retries
    # @raise [APIError] if API request fails
    # @raise [ParseError] if JSON parsing fails
    def fetch_instagram_data(username)
      validate_username!(username)
      log_api_call("Fetching data for username: #{username}")

      url = build_instagram_url(username)
      api_url = build_scrape_do_url(url)
      
      # Retry logic for temporary network errors
      response = with_retry(username) do
        make_request(api_url)
      end
      
      parse_response(response)
    rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout => e
      log_error("Timeout error for #{username}: #{e.class} - #{e.message}")
      raise TimeoutError, "Instagram API timeout: #{e.message}"
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
      log_error("Network error for #{username}: #{e.class} - #{e.message}")
      raise APIError, "Network error: #{e.message}"
    rescue JSON::ParserError => e
      log_error("JSON parse error for #{username}: #{e.message}")
      raise ParseError, "Invalid JSON response: #{e.message}"
    end
    
    # Retry logic for temporary network errors
    # @param username [String] Username for logging
    # @param max_retries [Integer] Maximum number of retries
    # @yield Block to execute with retry logic
    # @return [Object] Result of the block
    def with_retry(username, max_retries: 3)
      attempt = 0
      
      begin
        attempt += 1
        yield
      rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
        if attempt <= max_retries
          delay = 2 ** attempt # Exponential backoff: 2s, 4s, 8s
          log_error("Attempt #{attempt}/#{max_retries} failed for #{username}: #{e.class} - Retrying in #{delay}s...")
          sleep delay
          retry
        else
          log_error("All #{max_retries} attempts failed for #{username}: #{e.class} - #{e.message}")
          raise # Re-raise the exception after all retries are exhausted
        end
      end
    end

    # Validate Instagram username format
    # @param username [String] Username to validate
    # @raise [InvalidUsernameError] if username is invalid
    def validate_username!(username)
      if username.blank?
        raise InvalidUsernameError, 'Username cannot be blank'
      end

      unless username.match?(/\A[\w.]+\z/)
        raise InvalidUsernameError, "Invalid username format: #{username}"
      end

      if username.length > 30
        raise InvalidUsernameError, "Username too long: #{username}"
      end
    end

    # Build Instagram API URL
    # @param username [String] Instagram username
    # @return [String] Full Instagram API URL
    def build_instagram_url(username)
      "#{InstagramConfig::INSTAGRAM_API_BASE_URL}/users/web_profile_info/?username=#{username}"
    end

    # Build Scrape.do proxy URL
    # @param url [String] Target URL to scrape
    # @return [String] Full Scrape.do API URL
    def build_scrape_do_url(url)
      "#{InstagramConfig::SCRAPE_DO_API_URL}?token=#{InstagramConfig::SCRAPE_DO_TOKEN}&url=#{CGI.escape(url)}"
    end

    # Make HTTP request to Instagram API
    # @param api_url [String] API URL to call
    # @return [HTTParty::Response] Response object
    # @raise [APIError] if response status is not 200
    def make_request(api_url)
      headers = { 'x-ig-app-id' => InstagramConfig::INSTAGRAM_APP_ID }
      
      response = HTTParty.get(
        api_url,
        headers: headers,
        timeout: InstagramConfig::INSTAGRAM_API_TIMEOUT
      )
      
      # Check for HTTP errors
      unless response.success?
        case response.code
        when 404
          raise APIError, "Profile not found (404) - User may not exist or was deleted"
        when 429
          raise APIError, "Rate limit exceeded (429)"
        when 500..599
          raise APIError, "Instagram server error (#{response.code})"
        else
          raise APIError, "HTTP error #{response.code}"
        end
      end
      
      response
    end

    # Parse JSON response
    # @param response [HTTParty::Response] HTTP response
    # @return [Hash] Parsed JSON data
    def parse_response(response)
      JSON.parse(response.body)
    end

    # Log API call if logging is enabled
    # @param message [String] Log message
    def log_api_call(message)
      return unless InstagramConfig::LOG_API_CALLS
      
      Rails.logger.info("[InstagramAPI] #{message}")
    end

    # Log error message
    # @param message [String] Error message
    def log_error(message)
      Rails.logger.error("[InstagramAPI] #{message}")
    end

    # Validate that data hash contains required keys
    # @param data [Hash] Data hash to validate
    # @param keys [Array<String>] Required keys
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

