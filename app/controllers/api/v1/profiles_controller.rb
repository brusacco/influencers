# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApplicationController
      include Api::V1::Authenticable
      
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_api_token!, only: [:search]

      # GET /api/v1/profiles/search?q=query
      def search
        query = params[:q].to_s.strip
        
        if query.blank?
          render json: { profiles: [] }, status: :ok
          return
        end

        # Search by username or full_name, limit to 10 results
        profiles = Profile.paraguayos
                          .with_attached_avatar
                          .where('username LIKE ? OR full_name LIKE ?', "%#{query}%", "%#{query}%")
                          .order(followers: :desc)
                          .limit(10)

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

        render json: { profiles: results }, status: :ok
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

