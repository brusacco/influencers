# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :set_profile, only: %i[show]

  def index
    @profiles = Profile.order(followers: :desc).limit(20)
    @profiles_interactions = Profile.order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.order(total_video_view_count: :desc).limit(20)
    @profiles_engagement = Profile.order(engagement_rate: :desc).limit(20)
  end

  def show
    @profiles = Profile.where.not(id: @profile.id).order(followers: :desc).limit(12)
    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(12)

    @last_week_posts = @profile.instagram_posts.a_week_ago

    @related_brands = Profile.where(username: @profile.related_brands)

    @median_interactions = @profile.total_interactions_count / (@profile.total_posts + 1)
    @median_video_views = @profile.total_video_view_count / (@profile.total_posts + 1)
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
