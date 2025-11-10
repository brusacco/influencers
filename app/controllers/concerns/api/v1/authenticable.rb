# frozen_string_literal: true

module Api
  module V1
    module Authenticable
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_api_token!
      end

      private

      def authenticate_api_token!
        token = params[:token] || request.headers['Authorization']&.gsub('Bearer ', '')
        
        unless token.present? && valid_token?(token)
          render json: { error: 'Unauthorized - Invalid or missing API token' }, status: :unauthorized
        end
      end

      def valid_token?(token)
        api_token = ENV['API_TOKEN']
        
        return false if api_token.blank?
        
        ActiveSupport::SecurityUtils.secure_compare(token, api_token)
      end
    end
  end
end

