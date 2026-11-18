# frozen_string_literal: true

module InstagramServices
  # Fetches one public post detail query through Scrape.do to obtain its exact
  # publication timestamp, which is absent from the profile-grid response.
  class ScrapeDoGraphqlPostTimestampFetcher < ApplicationService
    POST_QUERY_NAME = 'PolarisLoggedOutDesktopWWWPostRootContentQuery'
    QUERY_ATTEMPTS = 3

    def initialize(post)
      @post = post
    end

    def call
      validate!

      query = fetch_post_query
      payload = scrape_do_post(graphql_url, graphql_form(query), graphql_headers(query))
      handle_success(extract_timestamp(JSON.parse(payload)))
    rescue JSON::ParserError
      handle_error('Scrape.do post detail GraphQL response was not JSON')
    rescue StandardError => e
      Rails.logger.error("[ScrapeDoGraphqlPostTimestampFetcher] #{@post&.shortcode}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate!
      raise ArgumentError, 'Instagram post cannot be nil' if @post.nil?
      raise ArgumentError, 'Instagram post shortcode is required' if @post.shortcode.blank?
    end

    def post_url
      @post.url.presence || "https://www.instagram.com/p/#{@post.shortcode}/"
    end

    def graphql_url
      'https://www.instagram.com/api/graphql/'
    end

    def scrape_do_get(target_url)
      response = HTTParty.get(InstagramConfig::SCRAPE_DO_API_URL, query: scrape_do_query(target_url), timeout: timeout)
      ensure_success!(response, 'post page')
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
      ensure_success!(response, 'post detail GraphQL request')
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

    def post_query(html)
      query_id, variables_json, query_name = html.scan(/"queryID":"(\d+)","variables":(\{[^{}]*\}),"queryName":"([^"]+)"/)
                                                .find { |_, _, name| name == POST_QUERY_NAME }
      raise 'Instagram did not expose the post detail GraphQL query' if query_id.blank?

      { query_id:, query_name:, variables: JSON.parse(variables_json) }
    end

    def fetch_post_query
      error = nil

      QUERY_ATTEMPTS.times do
        begin
          return post_query(scrape_do_get(post_url))
        rescue RuntimeError => e
          raise unless e.message == 'Instagram did not expose the post detail GraphQL query'

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

    def extract_timestamp(payload)
      media = find_media(payload)
      raise 'Instagram post detail GraphQL response did not include a publication timestamp' if media.nil?

      timestamp = media['taken_at'] || media['taken_at_timestamp']
      raise 'Instagram post detail GraphQL response did not include a publication timestamp' if timestamp.blank?

      Time.zone.at(Integer(timestamp))
    rescue ArgumentError, TypeError
      raise 'Instagram post detail GraphQL returned an invalid publication timestamp'
    end

    def find_media(value)
      case value
      when Hash
        return value if value['code'] == @post.shortcode && (value.key?('taken_at') || value.key?('taken_at_timestamp'))

        value.each_value do |child|
          media = find_media(child)
          return media if media
        end
      when Array
        value.each do |child|
          media = find_media(child)
          return media if media
        end
      end

      nil
    end
  end
end
