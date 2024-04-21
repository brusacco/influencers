# frozen_string_literal: true

module InstagramServices
  class UpdatePostData < ApplicationService
    def initialize(data, cursor = false)
      @data = data
      @cursor = cursor
    end

    def call
      return handle_error('Null data') if @data.nil?

      if @cursor
        likes_count = @data['node']['edge_media_preview_like']['count']
      else
        likes_count = @data['node']['edge_liked_by']['count']
      end
      comments_count = @data['node']['edge_media_to_comment']['count']

      response = {
        data: @data,
        media: @data['node']['__typename'],
        url: "https://www.instagram.com/p/#{@data['node']['shortcode']}",
        posted_at: Time.zone.at(Integer(@data['node']['taken_at_timestamp'])),
        comments_count: comments_count,
        likes_count: likes_count,
        video_view_count: @data['node']['video_view_count'],
        caption: @data['node']['edge_media_to_caption']['edges']&.first&.dig('node', 'text'),
        product_type: @data['node']['product_type'] || 'feed',
        total_count: likes_count + comments_count
      }
      handle_success(response)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
