# frozen_string_literal: true

module InstagramServices
  # Converts a Scrape.do GraphQL grid node to the safe, partial attributes
  # accepted by FerrumPostUpserter.
  class ScrapeDoGraphqlPostUpserter < ApplicationService
    MEDIA_TYPES = {
      1 => 'GraphImage',
      2 => 'GraphVideo',
      8 => 'GraphSidecar'
    }.freeze

    def initialize(profile, node)
      @profile = profile
      @node = node
    end

    def call
      validate!
      result = FerrumPostUpserter.call(@profile, attributes)
      return result unless result.success?

      populate_missing_publication_date(result.data)
      result
    rescue StandardError => e
      Rails.logger.error("[ScrapeDoGraphqlPostUpserter] @#{@profile&.username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate!
      raise ArgumentError, 'Profile cannot be nil' if @profile.nil?
      raise ArgumentError, 'GraphQL post shortcode is required' if @node['code'].blank?
    end

    def attributes
      video = @node['media_type'].to_i == 2
      likes_count = @node['like_count'] unless @node['like_and_view_counts_disabled']

      {
        shortcode: @node['code'],
        url: @node['seo_canonical_url'].presence || "https://www.instagram.com/p/#{@node['code']}/",
        media: MEDIA_TYPES[@node['media_type'].to_i] || (video ? 'GraphVideo' : 'GraphImage'),
        product_type: @node['product_type'] || (video ? 'reels' : 'feed'),
        caption: @node.dig('caption', 'text'),
        likes_count:,
        metadata: @node
      }.compact
    end

    def populate_missing_publication_date(post)
      return if post.posted_at.present?

      timestamp = ScrapeDoGraphqlPostTimestampFetcher.call(post)
      unless timestamp.success?
        Rails.logger.warn("[ScrapeDoGraphqlPostUpserter] #{post.shortcode}: publication date unavailable - #{timestamp.error}")
        return
      end

      post.update!(posted_at: timestamp.data)
    end
  end
end
