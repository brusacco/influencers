# frozen_string_literal: true

class CategoryController < ApplicationController
  def show
    @category = params[:category_id]
    @profiles = Profile.where(profile_type: @category).order(followers: :desc).limit(40)
    @profiles_interactions = Profile.where(profile_type: @category).order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.where(profile_type: @category).order(total_video_view_count: :desc).limit(20)
    @profiles_engagement = Profile.where(profile_type: @category).order(engagement_rate: :desc).limit(20)
    @profiles_disaster = Profile.where(profile_type: @category).where(total_posts: 0).order(followers: :desc).limit(20)
  end
end
