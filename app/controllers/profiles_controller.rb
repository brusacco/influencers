# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show]
  include ActiveStorage::SetCurrent
  include StorageHelper
  include SeoConcern

  def index
    expires_in CACHE_MEDIUM_DURATION, public: true

    @profiles = Profile.paraguayos.with_attached_avatar.order(followers: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar.order(total_interactions_count: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar.order(total_video_view_count: :desc).limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_disaster = Profile.paraguayos.with_attached_avatar.where(total_posts: 0).order(followers: :desc).limit(INACTIVE_PROFILES_LIMIT)

    set_profiles_index_meta_tags
  end

  def show
    expires_in CACHE_MEDIUM_DURATION, public: true

    # Use model methods for related profiles and data
    @profiles = @profile.related_profiles
    @mentions = @profile.mentions_profiles
    @posts = @profile.recent_posts
    @last_week_posts = @profile.instagram_posts.a_week_ago
    @collabs = @profile.recent_collaborations

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
    @profile = Profile.find(params[:id])
  end
end
