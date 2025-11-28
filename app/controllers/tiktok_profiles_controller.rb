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
      
      # Calculate estimated reach using model method
      @estimated_reach = @tiktok_profile.calculate_estimated_reach(
        total_interactions: @total_interactions_count,
        total_posts: @total_posts_count
      )
      @estimated_reach_percentage = @tiktok_profile.calculate_estimated_reach_percentage(
        total_interactions: @total_interactions_count,
        total_posts: @total_posts_count
      )
    end

    # Conditional GETs for caching
    fresh_when last_modified: @tiktok_profile.updated_at.utc, etag: @tiktok_profile
  end

  private

  def set_tiktok_profile
    @tiktok_profile = TiktokProfile.enabled.find(params[:id])
  end
end

