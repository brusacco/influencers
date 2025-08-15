# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    expires_in 30.minutes, public: true
    @tag = Tag.find_by(id: params[:id])

    unless @tag
      redirect_to root_path, alert: 'Tag not found'
      return
    end

    profile_ids = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(followers: :desc).limit(40).pluck(:id)
    @profiles = Profile.where(id: profile_ids)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar
                                    .tagged_with(@tag.name)
                                    .order(total_interactions_count: :desc)
                                    .limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar
                                   .tagged_with(@tag.name)
                                   .order(total_video_view_count: :desc)
                                   .limit(20)

    @posts = InstagramPost.where(profile_id: profile_ids).a_week_ago
  end
end
