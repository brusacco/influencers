# frozen_string_literal: true

# Instagram API Configuration
# This file loads configuration from environment variables for Instagram services
module InstagramConfig
  # Scrape.do API token - get from https://scrape.do
  SCRAPE_DO_TOKEN = ENV.fetch('SCRAPE_DO_TOKEN') do
    raise 'SCRAPE_DO_TOKEN environment variable is not set. Add it to your .env file.'
  end

  # Instagram App ID for API requests
  INSTAGRAM_APP_ID = ENV.fetch('INSTAGRAM_APP_ID', '936619743392459')

  # API request timeout in seconds
  INSTAGRAM_API_TIMEOUT = ENV.fetch('INSTAGRAM_API_TIMEOUT', '60').to_i

  # Instagram API base URL
  INSTAGRAM_API_BASE_URL = 'https://www.instagram.com/api/v1'

  # Scrape.do API base URL
  SCRAPE_DO_API_URL = 'http://api.scrape.do'

  # Rate limiting (requests per minute)
  RATE_LIMIT_PER_MINUTE = ENV.fetch('INSTAGRAM_RATE_LIMIT', '30').to_i

  # Retry configuration
  MAX_RETRIES = ENV.fetch('INSTAGRAM_MAX_RETRIES', '3').to_i
  RETRY_DELAY = ENV.fetch('INSTAGRAM_RETRY_DELAY', '2').to_i # seconds

  # Log API calls (useful for debugging)
  LOG_API_CALLS = ENV.fetch('LOG_INSTAGRAM_API_CALLS', 'false') == 'true'
end

