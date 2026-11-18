# frozen_string_literal: true

module InstagramServices
  # Retrieves public post metadata from Instagram's public web application.
  class FerrumPostsFetcher < ApplicationService
    PROFILE_POSTS_QUERY_NAME = 'PolarisLoggedOutDesktopWWWProfilePostsTabContentQuery'
    GRAPHQL_TEMPLATE_HEADER_NAMES = %w[
      x-asbd-id
      x-csrftoken
      x-fb-entry-nonce
      x-fb-lsd
      x-ig-app-id
      x-ig-max-touch-points
    ].freeze

    def initialize(profile, post_limit: InstagramConfig::FERRUM_POST_LIMIT)
      @profile = profile
      @post_limit = post_limit
    end

    def call
      validate_profile!

      browser = build_browser
      page = browser.create_page(**page_options)
      page.go_to(profile_url)
      page.network.wait_for_idle(connections: 2, timeout: InstagramConfig::FERRUM_TIMEOUT)

      posts = fetch_profile_posts(page)
      raise 'Instagram did not expose public GraphQL posts for this profile' if posts.empty?

      handle_success(posts)
    rescue StandardError => e
      Rails.logger.error("[FerrumPostsFetcher] @#{@profile&.username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    ensure
      browser&.quit
    end

    private

    def validate_profile!
      raise ArgumentError, 'Profile cannot be nil' if @profile.nil?
      raise ArgumentError, 'Profile must have a username' if @profile.username.blank?
      raise ArgumentError, 'Ferrum post limit must be positive' unless @post_limit.positive?
    end

    def build_browser
      Ferrum::Browser.new(
        timeout: InstagramConfig::FERRUM_TIMEOUT,
        process_timeout: InstagramConfig::FERRUM_TIMEOUT,
        browser_options: { 'ignore-certificate-errors' => nil }
      )
    end

    def page_options
      return {} unless InstagramConfig::FERRUM_USE_PROXY

      { proxy: InstagramConfig.ferrum_proxy }
    end

    def profile_url
      "https://www.instagram.com/#{@profile.username}/"
    end

    def fetch_profile_posts(page)
      query = profile_posts_query(page.body)
      response = execute_profile_posts_query(page, query)
      edges = response.dig('data', 'xig_user_by_username', 'polaris_ordered_timeline_connection', 'edges')

      Array(edges).filter_map { |edge| post_attributes(edge['node']) }.first(@post_limit)
    end

    def profile_posts_query(html)
      query_id, variables_json, = html.scan(
        /"queryID":"(\d+)","variables":(\{[^{}]*\}),"queryName":"([^"]+)"/
      ).find { |_, _, query_name| query_name == PROFILE_POSTS_QUERY_NAME }
      raise 'Instagram did not preload the profile posts GraphQL query' if query_id.blank?

      variables = JSON.parse(variables_json)
      variables['first'] = @post_limit
      variables['username'] = @profile.username
      variables['__relay_internal__pv__PolarisSEOIsCrawlerrelayprovider'] = true

      { query_id:, variables: }
    end

    def execute_profile_posts_query(page, query)
      template = page.network.traffic.find do |exchange|
        exchange.url&.include?('/api/graphql') && exchange.request&.post_data.present?
      end
      raise 'Instagram did not create a GraphQL request template' unless template

      form = URI.decode_www_form(template.request.post_data).to_h
      form['doc_id'] = query[:query_id]
      form['fb_api_req_friendly_name'] = PROFILE_POSTS_QUERY_NAME
      form['variables'] = query[:variables].to_json

      response = page.evaluate(<<~JS, graphql_payload(template, form))
        (async (payload) => {
          const response = await fetch('/api/graphql', {
            method: 'POST',
            headers: payload.headers,
            body: payload.body,
            credentials: 'same-origin'
          });

          return { status: response.status, text: await response.text() };
        })(arguments[0])
      JS

      raise "Instagram GraphQL returned HTTP #{response['status']}" unless response['status'] == 200

      JSON.parse(response['text'])
    rescue JSON::ParserError
      raise 'Instagram GraphQL returned a non-JSON response'
    end

    def graphql_payload(template, form)
      headers = template.request.headers.each_with_object({}) do |(name, value), result|
        result[name] = value if GRAPHQL_TEMPLATE_HEADER_NAMES.include?(name.downcase)
      end
      headers['Content-Type'] = 'application/x-www-form-urlencoded'
      headers['X-FB-Friendly-Name'] = PROFILE_POSTS_QUERY_NAME

      { headers:, body: URI.encode_www_form(form) }
    end

    def post_attributes(node)
      return if node.blank? || node['code'].blank?

      likes_count = node['like_count'] unless node['like_and_view_counts_disabled']
      video = node['media_type'].to_i == 2

      {
        shortcode: node['code'],
        url: node['seo_canonical_url'].presence || "https://www.instagram.com/p/#{node['code']}/",
        media: video ? 'GraphVideo' : 'GraphImage',
        product_type: node['product_type'] || (video ? 'reels' : 'feed'),
        caption: node.dig('caption', 'text'),
        likes_count:,
        metadata: node
      }.compact
    end
  end
end
