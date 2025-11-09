# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show]
  include ActiveStorage::SetCurrent
  include StorageHelper

  def index
    expires_in 60.minutes, public: true
    @profiles = Profile.paraguayos.with_attached_avatar.order(followers: :desc).limit(20)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar.order(total_interactions_count: :desc).limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar.order(total_video_view_count: :desc).limit(20)
    @profiles_disaster = Profile.paraguayos.with_attached_avatar.where(total_posts: 0).order(followers: :desc).limit(40)

    # SEO Meta Tags - Profiles Index
    set_meta_tags(
      title: "Top Influencers de Paraguay - Rankings 2024 | #{SITE_NAME}",
      description: "Descubre los influencers más destacados de Paraguay en 2024. Rankings por seguidores, engagement y visualizaciones. Análisis completo de más de 500 creadores de contenido paraguayos.",
      keywords: "top influencers Paraguay, ranking influencers paraguayos, mejores influencers Instagram Paraguay, creadores contenido Paraguay 2024, #{KEYWORDS}",
      canonical: profiles_url,
      og: {
        title: "Top Influencers de Paraguay - Rankings 2024",
        description: "Los influencers más destacados de Paraguay con análisis completo de métricas y engagement",
        type: 'website',
        url: profiles_url,
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "Top Influencers de Paraguay - Rankings 2024",
        description: "Los influencers más destacados de Paraguay con análisis completo de métricas"
      }
    )
  end

  def show
    expires_in 60.minutes, public: true
    if @profile.tags.any?
      @profiles = Profile.paraguayos.with_attached_avatar.tagged_with(
        @profile.tags.map(&:name),
        any: true
      ).where.not(id: @profile.id).order(followers: :desc).limit(12)
    elsif @profile.profile_type
      @profiles = Profile.paraguayos.with_attached_avatar.where(profile_type: @profile.profile_type)
                         .where.not(id: @profile.id)
                         .order(followers: :desc).limit(12)
    else
      @profiles = Profile.paraguayos.with_attached_avatar
                         .where.not(id: @profile.id)
                         .order(total_interactions_count: :desc).limit(12)
    end

    @mentions = Profile.where(username: @profile.mentions).limit(20)

    @posts = @profile.instagram_posts.order(posted_at: :desc).limit(20)

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

    # SEO Meta Tags - Profile Detail
    profile_description = @profile.biography.presence || "Perfil de #{@profile.full_name} (@#{@profile.username}) - #{number_to_human(@profile.followers)} seguidores. Descubre métricas, engagement rate y análisis completo de uno de los influencers más destacados de Paraguay."
    profile_keywords = "#{@profile.username}, #{@profile.full_name}, influencer Paraguay"
    profile_keywords += ", #{@profile.tags.pluck(:name).join(', ')}" if @profile.tags.any?
    profile_keywords += ", #{@profile.profile_type}" if @profile.profile_type.present?
    
    set_meta_tags(
      title: "#{@profile.full_name} (@#{@profile.username}) - Influencer #{@profile.profile_type&.capitalize} | #{SITE_NAME}",
      description: profile_description.truncate(155),
      keywords: "#{profile_keywords}, Instagram Paraguay, #{KEYWORDS}",
      canonical: profile_url(@profile),
      og: {
        title: "#{@profile.full_name} (@#{@profile.username})",
        description: profile_description.truncate(200),
        type: 'profile',
        url: profile_url(@profile),
        image: direct_blob_url(@profile.avatar),
        site_name: SITE_NAME,
        locale: 'es_PY',
        profile: {
          username: @profile.username,
          first_name: @profile.full_name.split.first,
          last_name: @profile.full_name.split.last
        }
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "#{@profile.full_name} (@#{@profile.username})",
        description: profile_description.truncate(200),
        image: direct_blob_url(@profile.avatar)
      },
      article: {
        published_time: @profile.created_at.iso8601,
        modified_time: @profile.updated_at.iso8601,
        tag: @profile.tags.pluck(:name)
      }
    )
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end
end
