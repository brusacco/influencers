# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      include Api::V1::Authenticable
      
      skip_before_action :verify_authenticity_token

      # GET /api/v1/posts?profile_type=marca
      def collection
        profile_type = params[:profile_type].to_s.strip

        if profile_type.present? && !Profile.profile_types.key?(profile_type)
          render json: { error: 'Invalid profile_type', valid_profile_types: Profile.profile_types.keys }, status: :unprocessable_entity
          return
        end

        posts = InstagramPost.a_day_ago
                             .joins(:profile)
                             .includes(:profile)
                             .order(posted_at: :desc)

        posts = posts.where(profiles: { profile_type: profile_type }) if profile_type.present?

        render json: {
          since: 24.hours.ago.iso8601,
          profile_type: profile_type.presence,
          total_posts: posts.count,
          posts: Instagram::Serializers::PostSerializer.collection(posts, include_profile: true)
        }, status: :ok
      end

      # GET /api/v1/profiles/:username/posts
      def index
        profile = Profile.find_by!(username: params[:username])
        posts = profile.instagram_posts
                       .order(posted_at: :desc)
                       .limit(100)

        render json: {
          profile_username: profile.username,
          total_posts: posts.count,
          posts: Instagram::Serializers::PostSerializer.collection(posts)
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Profile not found' }, status: :not_found
      end
    end
  end
end

