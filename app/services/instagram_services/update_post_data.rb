# frozen_string_literal: true

module InstagramServices
  # Service to parse and transform raw Instagram post data
  # Takes a post edge from the API response and extracts relevant fields
  # @example
  #   result = InstagramServices::UpdatePostData.call(post_edge, cursor: false)
  #   if result.success?
  #     post_attrs = result.data # Hash with post attributes
  #   end
  class UpdatePostData < ApplicationService
    # Required fields in post node
    REQUIRED_FIELDS = %w[
      __typename
      shortcode
      taken_at_timestamp
      edge_media_to_comment
    ].freeze

    # Media types
    MEDIA_TYPES = {
      'GraphImage' => 'image',
      'GraphVideo' => 'video',
      'GraphSidecar' => 'carousel'
    }.freeze

    def initialize(data, cursor: false)
      @data = data
      @cursor = cursor # cursor mode uses different field for likes
    end

    def call
      validate_data!
      
      node = extract_node
      validate_node_structure!(node)
      
      post_attrs = build_post_attributes(node)
      
      handle_success(post_attrs)
    rescue ArgumentError, StandardError => e
      Rails.logger.error("[UpdatePostData] Error: #{e.message}")
      handle_error(e.message)
    end

    private

    # Validate that data exists and has expected structure
    # @raise [ArgumentError] if data is invalid
    def validate_data!
      raise ArgumentError, 'Data cannot be nil' if @data.nil?
      raise ArgumentError, 'Data must be a Hash' unless @data.is_a?(Hash)
      raise ArgumentError, 'Missing node structure' unless @data['node']
    end

    # Extract node from data
    # @return [Hash] Post node data
    def extract_node
      @data['node']
    end

    # Validate that node contains required fields
    # @param node [Hash] Post node data
    # @raise [ArgumentError] if required fields are missing
    def validate_node_structure!(node)
      missing_fields = REQUIRED_FIELDS.reject { |field| node.key?(field) }
      
      return if missing_fields.empty?
      
      raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
    end

    # Build post attributes hash from node data
    # @param node [Hash] Post node data
    # @return [Hash] Post attributes
    def build_post_attributes(node)
      likes = extract_likes_count(node)
      comments = extract_comments_count(node)
      
      {
        # Raw data for debugging/archiving
        data: @data,
        
        # Media info
        media: MEDIA_TYPES[node['__typename']] || 'unknown',
        url: build_instagram_url(node['shortcode']),
        product_type: node['product_type'] || 'feed',
        
        # Timestamps
        posted_at: parse_timestamp(node['taken_at_timestamp']),
        
        # Engagement metrics
        comments_count: comments,
        likes_count: likes,
        video_view_count: node['video_view_count'],
        total_count: likes + comments,
        
        # Content
        caption: extract_caption(node)
      }
    end

    # Extract likes count based on cursor mode
    # @param node [Hash] Post node data
    # @return [Integer] Likes count
    def extract_likes_count(node)
      if @cursor
        node.dig('edge_media_preview_like', 'count') || 0
      else
        node.dig('edge_liked_by', 'count') || 0
      end
    end

    # Extract comments count
    # @param node [Hash] Post node data
    # @return [Integer] Comments count
    def extract_comments_count(node)
      node.dig('edge_media_to_comment', 'count') || 0
    end

    # Extract caption from edge structure
    # @param node [Hash] Post node data
    # @return [String, nil] Caption text
    def extract_caption(node)
      node.dig('edge_media_to_caption', 'edges')&.first&.dig('node', 'text')
    end

    # Build Instagram post URL
    # @param shortcode [String] Post shortcode
    # @return [String] Full Instagram URL
    def build_instagram_url(shortcode)
      "https://www.instagram.com/p/#{shortcode}"
    end

    # Parse Unix timestamp to Time object
    # @param timestamp [String, Integer] Unix timestamp
    # @return [Time] Parsed time object
    def parse_timestamp(timestamp)
      Time.zone.at(Integer(timestamp))
    rescue ArgumentError => e
      Rails.logger.error("[UpdatePostData] Invalid timestamp: #{timestamp}")
      raise ArgumentError, "Invalid timestamp: #{e.message}"
    end
  end
end
