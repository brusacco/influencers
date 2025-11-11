# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show]
  include ActiveStorage::SetCurrent
  include StorageHelper
  include SeoConcern

  def index
    # expires_in CACHE_MEDIUM_DURATION, public: true

    @profiles = Profile.enabled.paraguayos.with_attached_avatar.order(followers: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_interactions = Profile.enabled.paraguayos.with_attached_avatar.order(total_interactions_count: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_video_views = Profile.enabled.paraguayos.with_attached_avatar.order(total_video_view_count: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_disaster = Profile.enabled.paraguayos.with_attached_avatar.where(total_posts: 0).order(followers: :desc).limit(INACTIVE_PROFILES_LIMIT)

    set_profiles_index_meta_tags
  end

  def show
    # expires_in CACHE_MEDIUM_DURATION, public: true

    # Use model methods for related profiles and data
    @profiles = @profile.related_profiles
    @mentions = @profile.mentions_profiles
    @posts = @profile.recent_posts
    @last_week_posts = @profile.instagram_posts.a_week_ago
    @collabs = @profile.recent_collaborations

    # Historical data for charts
    @followers_history = @profile.instagram_profile_stats.order(:date).pluck(:date, :followers_count)
    
    # Calculate daily follower changes (growth/loss)
    if @followers_history.present?
      @followers_gains = []
      @followers_losses = []
      
      @followers_history.each_with_index do |(date, count), index|
        if index > 0
          previous_count = @followers_history[index - 1][1]
          change = count - previous_count
          
          # Separate positive and negative changes for different colors
          if change >= 0
            @followers_gains << [date, change]
            @followers_losses << [date, 0]
          else
            @followers_gains << [date, 0]
            @followers_losses << [date, change]
          end
        end
      end
    end

    # Calculate median metrics using model methods
    @median_interactions = @profile.median_interactions
    @median_video_views = @profile.median_video_views

    # Conditional GETs for caching
    fresh_when last_modified: @profile.updated_at.utc, etag: @profile

    # SEO Meta Tags
    set_profile_meta_tags(@profile)
  end

  private

  def set_profile
    @profile = Profile.enabled.find(params[:id])
  end
end
