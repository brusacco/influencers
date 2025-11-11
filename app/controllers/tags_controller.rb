# frozen_string_literal: true

class TagsController < ApplicationController
  include SeoConcern
  
  def index
    expires_in CACHE_MEDIUM_DURATION, public: true
    
    # Get all tags from enabled paraguayan profiles, ordered by usage count
    @tags = ActsAsTaggableOn::Tag
              .joins(:taggings)
              .joins("INNER JOIN profiles ON profiles.id = taggings.taggable_id AND taggings.taggable_type = 'Profile'")
              .where(profiles: { country_string: 'Paraguay', enabled: true })
              .select('tags.*, COUNT(taggings.id) as taggings_count')
              .group('tags.id')
              .order('taggings_count DESC')
              .to_a  # Execute the query and convert to array
    
    # SEO Meta Tags for Tags Index
    set_meta_tags(
      title: "Tags de Influencers Paraguay | #{SITE_NAME}",
      description: "Explora todos los tags y categorías de influencers paraguayos. Encuentra creadores de contenido por sus intereses, nichos y especialidades.",
      keywords: "tags influencers Paraguay, categorías influencers, hashtags Paraguay, #{KEYWORDS}",
      canonical: tags_url,
      og: {
        title: "Tags de Influencers Paraguay",
        description: "Explora influencers paraguayos por tags y categorías",
        type: 'website',
        url: tags_url,
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "Tags de Influencers Paraguay",
        description: "Explora influencers paraguayos por tags y categorías"
      }
    )
  end
  
  def show
    expires_in CACHE_SHORT_DURATION, public: true
    @tag = Tag.find_by(id: params[:id])

    unless @tag
      redirect_to root_path, alert: 'Tag not found'
      return
    end

    # Optimized: Use single query instead of two queries
    @profiles = Profile.enabled.paraguayos
                       .with_attached_avatar
                       .tagged_with(@tag.name)
                       .order(followers: :desc)
                       .limit(TOP_PROFILES_LIMIT)
    
    @profiles_interactions = Profile.enabled.paraguayos
                                    .with_attached_avatar
                                    .tagged_with(@tag.name)
                                    .order(total_interactions_count: :desc)
                                    .limit(ENGAGEMENT_PROFILES_LIMIT)
    
    @profiles_video_views = Profile.enabled.paraguayos
                                   .with_attached_avatar
                                   .tagged_with(@tag.name)
                                   .order(total_video_view_count: :desc)
                                   .limit(VIDEO_VIEWS_PROFILES_LIMIT)

    @posts = InstagramPost.where(profile_id: @profiles.pluck(:id)).a_week_ago
    
    # SEO Meta Tags
    set_tag_meta_tags(@tag, @profiles.size)
  end
end
