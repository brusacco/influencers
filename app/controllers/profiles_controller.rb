# frozen_string_literal: true

class ProfilesController < ApplicationController
  caches_page :show
  before_action :set_profile, only: %i[show]

  def index
    @profiles = Profile.paraguayos.order(followers: :desc).limit(20)
    @profiles_interactions = Profile.paraguayos.order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.paraguayos.order(total_video_view_count: :desc).limit(20)
    @profiles_engagement = Profile.paraguayos.order(engagement_rate: :desc).limit(20)
    @profiles_disaster = Profile.paraguayos.where(total_posts: 0).order(followers: :desc).limit(40)

    set_meta_tags title: 'Perfiles de Influencers | Influencers.com.py', description: DESCRIPTION, keywords: KEYWORDS
  end

  def show
    if @profile.profile_type
      @profiles = Profile.where(profile_type: @profile.profile_type).where.not(id: @profile.id).order(followers: :desc).limit(12)
    else
      @profiles = Profile.where.not(id: @profile.id).order(total_interactions_count: :desc).limit(12)
    end

    @mentions = Profile.where(username: @profile.mentions)

    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(12)

    @last_week_posts = @profile.instagram_posts.a_week_ago

    @related_brands = Profile.where(username: @profile.related_brands)

    @median_interactions = @profile.total_interactions_count / (@profile.total_posts + 1)
    @median_video_views = @profile.total_video_view_count / (@profile.total_posts + 1)

    set_meta_tags title: "#{@profile.username} | Influencers.com.py",
                  description: DESCRIPTION,
                  keywords: KEYWORDS,
                  og: {
                    title: :title,
                    site_name: 'Influencers.com.py',
                    description: :description,
                    image: url_for(@profile.avatar),
                    url: url_for(action: :show, id: @profile.id)
                  },
                  twitter: { card: 'summary' }
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
