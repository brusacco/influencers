# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper :storage

  # Handle specific exceptions with custom error pages
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActionController::InvalidAuthenticityToken, with: :render_unprocessable_entity

  private

  def render_not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found, layout: 'application' }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
    end
  end

  def render_unprocessable_entity
    respond_to do |format|
      format.html { render 'errors/unprocessable_entity', status: :unprocessable_entity, layout: 'application' }
      format.json { render json: { error: 'Unprocessable Entity' }, status: :unprocessable_entity }
    end
  end

  def render_internal_server_error
    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: :internal_server_error, layout: 'application' }
      format.json { render json: { error: 'Internal Server Error' }, status: :internal_server_error }
    end
  end
end
