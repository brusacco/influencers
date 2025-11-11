# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApplicationController
      include Api::V1::Authenticable
      
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_api_token!, only: [:search]

      # GET /api/v1/profiles/search?q=query&page=1
      def search
        query = params[:q].to_s.strip
        page = [params[:page].to_i, 1].max # Default to page 1, minimum 1
        per_page = 10
        offset = (page - 1) * per_page
        
        if query.blank?
          render json: { profiles: [], has_more: false }, status: :ok
          return
        end

            # Search by username or full_name with pagination (only enabled profiles)
            profiles = Profile.enabled.paraguayos
                              .with_attached_avatar
                              .where('username LIKE ? OR full_name LIKE ?', "%#{query}%", "%#{query}%")
                              .order(followers: :desc)
                              .limit(per_page + 1) # Get one extra to check if there are more
                              .offset(offset)

        # Check if there are more results
        has_more = profiles.size > per_page
        profiles = profiles.first(per_page) if has_more

        results = profiles.map do |profile|
          {
            id: profile.id,
            username: profile.username,
            full_name: profile.full_name,
            followers: profile.followers,
            avatar_url: profile.avatar.attached? ? url_for(profile.avatar) : nil,
            profile_url: profile_path(profile)
          }
        end

        render json: { profiles: results, has_more: has_more }, status: :ok
      end

      # GET /api/v1/profiles/:username
      def show
        profile = Profile.find_by!(username: params[:username])
        
        render json: Instagram::Serializers::ProfileSerializer.new(profile).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Profile not found' }, status: :not_found
      end
    end
  end
end

