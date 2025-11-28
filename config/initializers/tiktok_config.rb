# frozen_string_literal: true

# TikTok API Configuration
# This file loads configuration from environment variables for TikTok services
module TikTokConfig
  # TikAPI.io API Key
  API_KEY = ENV.fetch('TIKTOK_API_KEY') do
    raise 'TIKTOK_API_KEY environment variable is not set. Add it to your .env file.'
  end

  # API base URL
  API_BASE_URL = 'https://api.tikapi.io'

  # API request timeout in seconds
  API_TIMEOUT = ENV.fetch('TIKTOK_API_TIMEOUT', '60').to_i

  # Rate limiting (requests per minute)
  RATE_LIMIT_PER_MINUTE = ENV.fetch('TIKTOK_RATE_LIMIT', '30').to_i

  # Retry configuration
  MAX_RETRIES = ENV.fetch('TIKTOK_MAX_RETRIES', '3').to_i
  RETRY_DELAY = ENV.fetch('TIKTOK_RETRY_DELAY', '2').to_i # seconds

  # Log API calls (useful for debugging)
  LOG_API_CALLS = ENV.fetch('LOG_TIKTOK_API_CALLS', 'false') == 'true'
end

