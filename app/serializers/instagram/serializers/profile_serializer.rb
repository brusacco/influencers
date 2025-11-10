# frozen_string_literal: true

module Instagram
  module Serializers
    class ProfileSerializer
      attr_reader :profile

      def initialize(profile)
        @profile = profile
      end

      def as_json
        {
          id: profile.id,
          username: profile.username,
          uid: profile.uid,
          full_name: profile.full_name,
          biography: profile.biography,
          profile_type: profile.profile_type,
          followers: profile.followers,
          following: profile.following,
          is_verified: profile.is_verified,
          is_business_account: profile.is_business_account,
          is_professional_account: profile.is_professional_account,
          is_private: profile.is_private,
          is_joined_recently: profile.is_joined_recently,
          is_embeds_disabled: profile.is_embeds_disabled,
          country_string: profile.country_string,
          category_name: profile.category_name,
          category_enum: profile.category_enum,
          business_category_name: profile.business_category_name,
          profile_pic_url: profile.profile_pic_url,
          profile_pic_url_hd: profile.profile_pic_url_hd,
          engagement_rate: profile.engagement_rate,
          total_posts: profile.total_posts,
          total_videos: profile.total_videos,
          total_likes_count: profile.total_likes_count,
          total_comments_count: profile.total_comments_count,
          total_video_view_count: profile.total_video_view_count,
          total_interactions_count: profile.total_interactions_count,
          median_interactions: profile.median_interactions,
          median_video_views: profile.median_video_views,
          estimated_reach: profile.estimated_reach,
          estimated_reach_percentage: profile.estimated_reach_percentage,
          tags: profile.tags.pluck(:name),
          created_at: profile.created_at,
          updated_at: profile.updated_at
        }
      end

      # Método de clase para serializar una colección
      def self.collection(profiles)
        profiles.map { |profile| new(profile).as_json }
      end
    end
  end
end

