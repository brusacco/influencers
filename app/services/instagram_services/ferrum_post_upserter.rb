# frozen_string_literal: true

module InstagramServices
  # Persists Ferrum data without replacing existing values with incomplete
  # public-page metadata.
  class FerrumPostUpserter < ApplicationService
    METADATA_KEYS = %w[
      __typename
      id
      pk
      code
      media_type
      product_type
      seo_canonical_url
      display_uri
      like_count
      like_and_view_counts_disabled
    ].freeze

    def initialize(profile, attributes)
      @profile = profile
      @attributes = attributes
    end

    def call
      validate!

      post = @profile.instagram_posts.find_or_initialize_by(shortcode: @attributes.fetch(:shortcode))
      post.assign_attributes(persisted_attributes)
      post.data = (post.data || {}).merge('ferrum' => compact_metadata)
      post.save!

      handle_success(post)
    rescue StandardError => e
      Rails.logger.error("[FerrumPostUpserter] @#{@profile&.username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate!
      raise ArgumentError, 'Profile cannot be nil' if @profile.nil?
      raise ArgumentError, 'Post shortcode is required' if @attributes[:shortcode].blank?
    end

    def persisted_attributes
      @attributes.slice(
        :url,
        :media,
        :product_type,
        :caption,
        :posted_at,
        :likes_count,
        :comments_count,
        :total_count
      ).compact
    end

    def compact_metadata
      @attributes.fetch(:metadata, {}).slice(*METADATA_KEYS)
    end
  end
end
