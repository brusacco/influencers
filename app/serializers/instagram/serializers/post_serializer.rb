# frozen_string_literal: true

module Instagram
  module Serializers
    class PostSerializer
      include Rails.application.routes.url_helpers
      attr_reader :post

      def initialize(post)
        @post = post
      end

      def as_json
        {
          id: post.id,
          shortcode: post.shortcode,
          url: post.url,
          caption: post.caption,
          media: post.media,
          product_type: post.product_type,
          posted_at: post.posted_at,
          likes_count: post.likes_count,
          comments_count: post.comments_count,
          video_view_count: post.video_view_count,
          total_count: post.total_count,
          post_image_url: post_image_url,
          profile_id: post.profile_id,
          created_at: post.created_at,
          updated_at: post.updated_at
        }
      end

      # Serialización con información del perfil incluida
      def as_json_with_profile
        as_json.merge(
          profile: {
            id: post.profile.id,
            username: post.profile.username,
            full_name: post.profile.full_name,
            profile_pic_url: post.profile.profile_pic_url
          }
        )
      end

      # Método de clase para serializar una colección
      def self.collection(posts, include_profile: false)
        posts.map do |post|
          serializer = new(post)
          include_profile ? serializer.as_json_with_profile : serializer.as_json
        end
      end

      private

      def post_image_url
        return nil unless post.image.attached?

        blob = post.image
        return nil unless blob&.key

        if Rails.env.production?
          prefix = '/blob_files'
          key = blob.key
          "https://www.influencers.com.py#{prefix}/#{key[0..1]}/#{key[2..3]}/#{key}"
        else
          # fallback to normal Rails route in dev
          url_for(blob)
        end
      end
    end
  end
end

