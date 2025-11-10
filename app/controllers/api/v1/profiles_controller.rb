# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApplicationController
      include Api::V1::Authenticable
      
      skip_before_action :verify_authenticity_token

      # GET /api/v1/profiles/:username
      def show
        profile = Profile.find_by!(username: params[:username])
        
        render json: ProfileSerializer.new(profile).as_json, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Profile not found' }, status: :not_found
      end
    end
  end
end

