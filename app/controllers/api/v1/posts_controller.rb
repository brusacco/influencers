# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      include Api::V1::Authenticable
      
      skip_before_action :verify_authenticity_token

      # GET /api/v1/profiles/:username/posts
      def index
        profile = Profile.find_by!(username: params[:username])
        posts = profile.instagram_posts
                       .order(posted_at: :desc)
                       .limit(100)

        render json: {
          profile_username: profile.username,
          total_posts: posts.count,
          posts: InstagramPostSerializer.collection(posts)
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Profile not found' }, status: :not_found
      end
    end
  end
end

