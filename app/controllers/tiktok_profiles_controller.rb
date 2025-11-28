# frozen_string_literal: true

class TiktokProfilesController < ApplicationController
  before_action :set_tiktok_profile, only: %i[show]
  include ActiveStorage::SetCurrent
  include StorageHelper
  include SeoConcern

  def index
    @tiktok_profiles = TiktokProfile.enabled.paraguayos.order(followers: :desc)
  end

  def show
    @posts = @tiktok_profile.tiktok_posts.order(posted_at: :desc).limit(50)
    @last_week_posts = @tiktok_profile.tiktok_posts.a_week_ago

    # Calculate metrics for last week posts
    if @last_week_posts.any?
      @total_posts_count = @last_week_posts.count
      @total_interactions_count = @last_week_posts.sum(:total_count)
      @total_play_count = @last_week_posts.sum(:play_count)
      @total_likes_count = @last_week_posts.sum(:likes_count)
      @total_comments_count = @last_week_posts.sum(:comments_count)
      @total_shares_count = @last_week_posts.sum(:shares_count)
      
      # Calculate estimated reach (similar to Instagram)
      @estimated_reach = calculate_estimated_reach
      @estimated_reach_percentage = @tiktok_profile.followers > 0 ? 
        (@estimated_reach.to_f / @tiktok_profile.followers * 100).round(2) : 0.0
    end

    # Conditional GETs for caching
    fresh_when last_modified: @tiktok_profile.updated_at.utc, etag: @tiktok_profile
  end

  private

  def calculate_estimated_reach
    return 0 if @tiktok_profile.followers.zero? || @total_posts_count.zero?

    # Método 1: Basado en followers (15% engagement promedio)
    follower_based_reach = @tiktok_profile.followers * 0.15

    # Método 2: Basado en interacciones (asumiendo 10% de interacciones = reach)
    interaction_based_reach = @total_interactions_count * 10

    # Promedio ponderado (60% followers, 40% interactions)
    weighted_reach = (follower_based_reach * 0.6) + (interaction_based_reach * 0.4)

    # Cap máximo: nunca más del 50% de followers
    max_reach = @tiktok_profile.followers * 0.5

    [weighted_reach, max_reach].min.round
  end

  private

  def set_tiktok_profile
    @tiktok_profile = TiktokProfile.enabled.find(params[:id])
  end
end

