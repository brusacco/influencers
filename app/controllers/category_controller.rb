# frozen_string_literal: true

class CategoryController < ApplicationController
  include ActiveStorage::SetCurrent
  include SeoConcern
  
  def show
    expires_in CACHE_SHORT_DURATION, public: true
    @category = params[:category_id]

    unless @category
      redirect_to root_path, alert: 'Category not found'
      return
    end

    @profiles = Profile.paraguayos.where(profile_type: @category).order(followers: :desc).limit(TOP_PROFILES_LIMIT)
    @profiles_interactions = Profile.paraguayos
                                    .where(profile_type: @category)
                                    .order(total_interactions_count: :desc)
                                    .limit(ENGAGEMENT_PROFILES_LIMIT)
    @profiles_video_views = Profile.paraguayos
                                   .where(profile_type: @category)
                                   .order(total_video_view_count: :desc)
                                   .limit(VIDEO_VIEWS_PROFILES_LIMIT)

    # SEO Meta Tags
    set_category_meta_tags(@category, @profiles.size)
  end
end
