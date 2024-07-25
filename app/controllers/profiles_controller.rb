# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show]
  include ActiveStorage::SetCurrent

  def index
    expires_in 30.minutes, public: true
    @profiles = Profile.paraguayos.with_attached_avatar.order(followers: :desc).limit(20)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar.order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar.order(total_video_view_count: :desc).limit(20)
    @profiles_disaster = Profile.paraguayos.with_attached_avatar.where(total_posts: 0).order(followers: :desc).limit(40)

    set_meta_tags title: 'Perfiles de Influencers | Influencers.com.py', description: DESCRIPTION, keywords: KEYWORDS
  end

  def show
    expires_in 30.minutes, public: true
    if @profile.profile_type
      @profiles = Profile.paraguayos.with_attached_avatar.where(profile_type: @profile.profile_type).where.not(id: @profile.id).order(followers: :desc).limit(12)
    else
      @profiles = Profile.paraguayos.with_attached_avatar.where.not(id: @profile.id).order(total_interactions_count: :desc).limit(12)
    end

    @mentions = Profile.where(username: @profile.mentions)

    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(12)

    @last_week_posts = @profile.instagram_posts.a_week_ago

    @related_brands = Profile.where(username: @profile.related_brands)

    @median_interactions = @profile.total_interactions_count / (@profile.total_posts + 1)

    if @profile.total_videos.zero?
      @median_video_views = 0
    else
      @median_video_views = @profile.total_video_view_count / @profile.total_videos
    end

    @collabs = @profile.collaborated_collaborations.includes(:instagram_post).order(posted_at: :desc).limit(12)

    # Conditional GETs are a feature of the HTTP specification that
    # provide a way for web servers
    # to tell browsers that the response
    # to a GET request hasn't changed since the last request
    # and can be safely pulled from the browser cache.
    fresh_when last_modified: @profile.updated_at.utc, etag: @profile

    set_meta_tags title: "#{@profile.username} | Influencers.com.py",
                  description: DESCRIPTION,
                  keywords: KEYWORDS,
                  og: {
                    title: :title,
                    site_name: 'Influencers.com.py',
                    description: :description,
                    image: @profile.avatar.url,
                    url: url_for(action: :show, id: @profile.id)
                  },
                  twitter: { card: 'summary' }
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
