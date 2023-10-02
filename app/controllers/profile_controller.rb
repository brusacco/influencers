# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :set_profile, only: %i[show]

  def index
    @profiles = Profile.order(followers: :desc).limit(40)
  end

  def show
    @profiles = Profile.where.not(id: @profile.id).order(followers: :desc).limit(12)
    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(12)
    @stats_posts = @profile.instagram_posts.a_week_ago

    @engagement_rate = (@stats_posts.sum(:total_count) / Float(@profile.followers) * 100).round
    @engagement_median = @stats_posts.sum(:total_count) / (@stats_posts.count + 1)

    @video_total = @stats_posts.count
    @video_total_views = @stats_posts.sum(:video_view_count)
    @video_total_median = @video_total_views / (@video_total + 1)
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
