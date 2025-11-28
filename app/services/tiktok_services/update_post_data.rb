# frozen_string_literal: true

module TiktokServices
  # Service to parse and transform raw TikTok post data
  # Takes a post from itemList array and extracts relevant fields
  # @example
  #   result = TiktokServices::UpdatePostData.call(post_data)
  #   if result.success?
  #     post_attrs = result.data # Hash with post attributes
  #   end
  class UpdatePostData < Base
    # Required fields in post data
    REQUIRED_FIELDS = %w[
      id
      createTime
    ].freeze

    def initialize(data)
      @data = data
    end

    def call
      validate_data!
      validate_post_structure!
      
      post_attrs = build_post_attributes
      
      handle_success(post_attrs)
    rescue StandardError => e
      Rails.logger.error("[TiktokServices::UpdatePostData] Error: #{e.message}")
      handle_error(e.message)
    end

    private

    # Validate that data exists and has expected structure
    # @raise [ArgumentError] if data is invalid
    def validate_data!
      raise ArgumentError, 'Data cannot be nil' if @data.nil?
      raise ArgumentError, 'Data must be a Hash' unless @data.is_a?(Hash)
    end

    # Validate that post contains required fields
    # @raise [ArgumentError] if required fields are missing
    def validate_post_structure!
      missing_fields = REQUIRED_FIELDS.reject { |field| @data.key?(field) }
      
      return if missing_fields.empty?
      
      raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
    end

    # Build post attributes hash from post data
    # @return [Hash] Post attributes
    def build_post_attributes
      stats = @data['stats'] || {}
      video = @data['video'] || {}
      music = @data['music'] || {}

      likes_count = safe_integer(stats['diggCount'])
      comments_count = safe_integer(stats['commentCount'])
      shares_count = safe_integer(stats['shareCount'])
      collects_count = safe_integer(stats['collectCount'])

      {
        # Raw data for debugging/archiving
        data: @data,

        # Basic info
        tiktok_post_id: @data['id'],
        desc: @data['desc'],
        posted_at: parse_timestamp(@data['createTime']),

        # Stats
        likes_count: likes_count,
        comments_count: comments_count,
        play_count: safe_integer(stats['playCount']),
        shares_count: shares_count,
        collects_count: collects_count,
        total_count: likes_count + comments_count + shares_count + collects_count,

        # Video info
        video_url: video['playAddr'],
        cover_url: video['cover'],
        dynamic_cover_url: video['dynamicCover'],
        video_duration: safe_integer(video['duration']),
        video_definition: video['definition'] || video['ratio'],

        # Music info
        music_title: music['title'],
        music_author: music['authorName'],
        music_play_url: music['playUrl']
      }
    end

  end
end

