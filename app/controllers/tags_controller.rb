# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @profiles = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(followers: :desc).limit(40)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(total_video_view_count: :desc).limit(20)
    @profiles_engagement = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(engagement_rate: :desc).limit(20)
    @profiles_disaster = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).where(total_posts: 0).order(followers: :desc).limit(20)
  end
end
