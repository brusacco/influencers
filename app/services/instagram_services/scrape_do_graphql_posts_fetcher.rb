# frozen_string_literal: true

module InstagramServices
  # Experimental collector that keeps both the profile page and GraphQL request
  # behind Scrape.do's API instead of routing a local browser through its proxy.
  class ScrapeDoGraphqlPostsFetcher < ApplicationService
    PROFILE_POSTS_QUERY_NAME = 'PolarisProfilePostsLoggedOutTabGridUIContentQuery'
    PROFILE_QUERY_ATTEMPTS = 3

    def initialize(username, post_limit: InstagramConfig::FERRUM_POST_LIMIT)
      @username = username
      @post_limit = post_limit
    end

    def call
      validate!

      query = fetch_profile_posts_query
      payload = scrape_do_post(graphql_url, graphql_form(query), graphql_headers(query))
      handle_success(extract_posts(JSON.parse(payload)))
    rescue JSON::ParserError
      handle_error('Scrape.do GraphQL response was not JSON')
    rescue StandardError => e
      Rails.logger.error("[ScrapeDoGraphqlPostsFetcher] @#{@username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate!
      raise ArgumentError, 'Username is required' if @username.blank?
      raise ArgumentError, 'Post limit must be positive' unless @post_limit.positive?
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

    # Scrape.do forwards the request method, headers, and body to the target
    # when they are included on its API request.
    def scrape_do_post(target_url, form, headers)
      response = HTTParty.post(
        InstagramConfig::SCRAPE_DO_API_URL,
        query: scrape_do_query(target_url).merge(customHeaders: true),
        body: URI.encode_www_form(form),
        headers:,
        timeout: timeout
      )
      ensure_success!(response, 'GraphQL request')
      response.body
    end

    def scrape_do_query(target_url)
      {
        token: InstagramConfig::SCRAPE_DO_TOKEN,
        super: true,
        url: target_url
      }
    end

    def timeout
      InstagramConfig::INSTAGRAM_API_TIMEOUT
    end

    def ensure_success!(response, request_name)
      return if response.success?

      raise "Scrape.do #{request_name} returned HTTP #{response.code}"
    end

    def profile_posts_query(html)
      matches = html.scan(/"queryID":"(\d+)","variables":(\{[^{}]*\}),"queryName":"([^"]+)"/)
      query_id, variables_json, query_name = matches.find { |_, _, name| name == PROFILE_POSTS_QUERY_NAME }
      raise 'Instagram did not expose the profile posts GraphQL query' if query_id.blank?

      variables = JSON.parse(variables_json)
      variables['first'] = @post_limit

      { query_id:, query_name:, variables: }
    end

    def fetch_profile_posts_query
      error = nil

      PROFILE_QUERY_ATTEMPTS.times do
        begin
          return profile_posts_query(scrape_do_get(profile_url))
        rescue RuntimeError => e
          raise unless e.message == 'Instagram did not expose the profile posts GraphQL query'

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

    def extract_posts(payload)
      nodes = Array(payload.dig('data', 'xig_user_by_igid_v2', 'polaris_timeline_connection', 'edges')).filter_map do |edge|
        edge['node'] if edge.is_a?(Hash)
      end

      if nodes.empty?
        nodes = []
        collect_post_nodes(payload, nodes)
      end

      nodes.each { |node| node['code'] ||= shortcode_from_pk(node['pk']) }
      nodes.select { |node| node['code'].present? }.uniq { |node| node['code'] }.first(@post_limit)
    end

    def collect_post_nodes(value, nodes)
      case value
      when Hash
        nodes << value if value['code'].present? || value['pk'].present?
        value.each_value { |child| collect_post_nodes(child, nodes) }
      when Array
        value.each { |child| collect_post_nodes(child, nodes) }
      end
    end

    # Instagram's public media primary key encodes the shortcode with its
    # URL-safe base-64 alphabet when GraphQL omits the `code` field.
    def shortcode_from_pk(primary_key)
      value = Integer(primary_key)
      return if value <= 0

      alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
      shortcode = +''
      while value.positive?
        shortcode.prepend(alphabet[value % 64])
        value /= 64
      end
      shortcode
    rescue ArgumentError, TypeError
      nil
    end
  end
end
