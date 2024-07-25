# frozen_string_literal: true

class CategoryController < ApplicationController
  include ActiveStorage::SetCurrent
  def show
    expires_in 30.minutes, public: true
    @category = params[:category_id]
    @profiles = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).order(followers: :desc).limit(40)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).order(total_video_view_count: :desc).limit(20)
    @profiles_engagement = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).order(engagement_rate: :desc).limit(20)
    @profiles_disaster = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).where(total_posts: 0).order(followers: :desc).limit(20)

    set_meta_tags title: "Top Influencers categoría #{@category.capitalize} | Influencers.com.py",
                  description: DESCRIPTION,
                  keywords: KEYWORDS
  end
end
