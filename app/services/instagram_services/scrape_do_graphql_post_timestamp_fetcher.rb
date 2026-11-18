# frozen_string_literal: true

module InstagramServices
  # Fetches one public post detail query through Scrape.do to obtain fields
  # absent from the profile-grid response, including its publication timestamp
  # and comment count.
  class ScrapeDoGraphqlPostTimestampFetcher < ApplicationService
    POST_QUERY_NAME = 'PolarisLoggedOutDesktopWWWPostRootContentQuery'
    QUERY_ATTEMPTS = 3
    DETAIL_METADATA_KEYS = %w[
      __typename
      id
      pk
      code
      media_type
      product_type
      seo_canonical_url
      display_uri
      original_height
      original_width
      accessibility_caption
      caption_is_edited
      commenting_disabled_for_viewer
      like_and_view_counts_disabled
      related_topic_pills
      seo_original_audio
      taken_at
      taken_at_timestamp
      comment_count
      like_count
      video_view_count
    ].freeze

    def initialize(post)
      @post = post
    end

    def call
      validate!

      query = fetch_post_query
      payload = scrape_do_post(graphql_url, graphql_form(query), graphql_headers(query))
      handle_success(extract_details(JSON.parse(payload)))
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

    def extract_details(payload)
      media = find_media(payload)
      raise 'Instagram post detail GraphQL response did not include a publication timestamp' if media.nil?

      timestamp = media['taken_at'] || media['taken_at_timestamp']
      raise 'Instagram post detail GraphQL response did not include a publication timestamp' if timestamp.blank?

      {
        posted_at: Time.zone.at(Integer(timestamp)),
        comments_count: media['comment_count'].to_i,
        likes_count: media['like_count'],
        metadata: compact_metadata(media)
      }.compact
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

    def compact_metadata(media)
      media.slice(*DETAIL_METADATA_KEYS)
           .merge(
             'caption' => media['caption']&.slice('pk', 'text', 'created_at'),
             'user' => compact_user(media['user']),
             'coauthor_producers' => compact_users(media['coauthor_producers']),
             'usertags' => compact_usertags(media['usertags']),
             'location' => media['location']&.slice('id', 'pk', 'name', 'short_name', 'address', 'city', 'lat', 'lng')
           )
           .compact
    end

    def compact_users(users)
      return unless users.is_a?(Array)

      users.filter_map { |user| compact_user(user) }
    end

    def compact_usertags(usertags)
      return unless usertags.is_a?(Hash)

      tagged_users = Array(usertags['in']).filter_map do |tag|
        next unless tag.is_a?(Hash)

        tag.slice('position').merge('user' => compact_user(tag['user'])).compact
      end
      return if tagged_users.empty?

      { 'in' => tagged_users }
    end

    def compact_user(user)
      return unless user.is_a?(Hash)

      user.slice('id', 'pk', 'username', 'full_name', 'is_verified', 'is_private', 'profile_pic_url', 'seo_canonical_url')
    end
  end
end
