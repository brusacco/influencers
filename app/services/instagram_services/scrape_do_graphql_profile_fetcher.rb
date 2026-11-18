# frozen_string_literal: true

module InstagramServices
  # Fetches the public profile root query through Scrape.do's API.
  class ScrapeDoGraphqlProfileFetcher < ApplicationService
    PROFILE_QUERY_NAME = 'PolarisLoggedOutMobileProfileRootQuery'
    PROFILE_QUERY_ATTEMPTS = 3

    def initialize(username)
      @username = username
    end

    def call
      validate_username!

      query = fetch_profile_query
      payload = scrape_do_post(graphql_url, graphql_form(query), graphql_headers(query))
      handle_success(extract_profile(JSON.parse(payload)))
    rescue JSON::ParserError
      handle_error('Scrape.do profile GraphQL response was not JSON')
    rescue StandardError => e
      Rails.logger.error("[ScrapeDoGraphqlProfileFetcher] @#{@username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate_username!
      raise ArgumentError, 'Username is required' if @username.blank?
    end

    def profile_url
      "https://www.instagram.com/#{@username}/"
    end

    def graphql_url
      'https://www.instagram.com/api/graphql/'
    end

    def scrape_do_get(target_url)
      response = HTTParty.get(InstagramConfig::SCRAPE_DO_API_URL, query: scrape_do_query(target_url), timeout: timeout)
      ensure_success!(response, 'profile page')
      response.body
    end

    def scrape_do_post(target_url, form, headers)
      response = HTTParty.post(
        InstagramConfig::SCRAPE_DO_API_URL,
        query: scrape_do_query(target_url).merge(customHeaders: true),
        body: URI.encode_www_form(form),
        headers:,
        timeout: timeout
      )
      ensure_success!(response, 'profile GraphQL request')
      response.body
    end

    def scrape_do_query(target_url)
      { token: InstagramConfig::SCRAPE_DO_TOKEN, super: true, url: target_url }
    end

    def timeout
      InstagramConfig::INSTAGRAM_API_TIMEOUT
    end

    def ensure_success!(response, request_name)
      return if response.success?

      raise "Scrape.do #{request_name} returned HTTP #{response.code}"
    end

    def profile_query(html)
      query_id, variables_json, query_name = html.scan(/"queryID":"(\d+)","variables":(\{[^{}]*\}),"queryName":"([^"]+)"/)
                                                .find { |_, _, name| name == PROFILE_QUERY_NAME }
      raise 'Instagram did not expose the profile root GraphQL query' if query_id.blank?

      { query_id:, query_name:, variables: JSON.parse(variables_json) }
    end

    def fetch_profile_query
      error = nil

      PROFILE_QUERY_ATTEMPTS.times do
        begin
          return profile_query(scrape_do_get(profile_url))
        rescue RuntimeError => e
          raise unless e.message == 'Instagram did not expose the profile root GraphQL query'

          error = e
        end
      end

      raise error
    end

    def graphql_form(query)
      {
        doc_id: query[:query_id],
        fb_api_req_friendly_name: query[:query_name],
        variables: query[:variables].to_json
      }
    end

    def graphql_headers(query)
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'X-IG-App-ID' => InstagramConfig::INSTAGRAM_APP_ID,
        'X-ASBD-ID' => '359341',
        'X-FB-Friendly-Name' => query[:query_name]
      }
    end

    def extract_profile(payload)
      profile = payload.dig('data', 'xig_user_by_igid_v2')
      raise 'Instagram GraphQL response did not include profile data' unless profile.is_a?(Hash)
      raise 'Instagram GraphQL response did not include a username' if profile['username'].blank?

      profile
    end
  end
end
