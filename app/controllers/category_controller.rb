# frozen_string_literal: true

class CategoryController < ApplicationController
  include ActiveStorage::SetCurrent
  def show
    expires_in 30.minutes, public: true
    @category = params[:category_id]

    unless @category
      redirect_to root_path, alert: 'Category not found'
      return
    end

    @profiles = Profile.paraguayos.with_attached_avatar.where(profile_type: @category).order(followers: :desc).limit(40)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar
                                    .where(profile_type: @category)
                                    .order(total_interactions_count: :desc)
                                    .limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar
                                   .where(profile_type: @category)
                                   .order(total_video_view_count: :desc)
                                   .limit(20)

    @posts = InstagramPost.joins(:profile)
                          .where(profiles: { profile_type: @category })
                          .order(posted_at: :desc)
                          .limit(20)

    @popular_posts = InstagramPost.joins(:profile)
                                  .where(profiles: { profile_type: @category })
                                  .order(posted_at: :desc, total_count: :desc)
                                  .limit(20)

    set_meta_tags title: "Top Influencers categoría #{@category.capitalize} | Influencers.com.py",
                  description: DESCRIPTION,
                  keywords: KEYWORDS
  end
end
