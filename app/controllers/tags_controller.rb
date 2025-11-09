# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    expires_in 30.minutes, public: true
    @tag = Tag.find_by(id: params[:id])

    unless @tag
      redirect_to root_path, alert: 'Tag not found'
      return
    end

    profile_ids = Profile.paraguayos.with_attached_avatar.tagged_with(@tag.name).order(followers: :desc).limit(40).ids

    @profiles = Profile.where(id: profile_ids).order(followers: :desc)
    @profiles_interactions = Profile.paraguayos.with_attached_avatar
                                    .tagged_with(@tag.name)
                                    .order(total_interactions_count: :desc)
                                    .limit(20)
    @profiles_video_views = Profile.paraguayos.with_attached_avatar
                                   .tagged_with(@tag.name)
                                   .order(total_video_view_count: :desc)
                                   .limit(20)

    @posts = InstagramPost.where(profile_id: profile_ids).a_week_ago
    
    # SEO Meta Tags - Tag Page
    tag_name = @tag.name.titleize
    total_profiles = @profiles.size
    
    set_meta_tags(
      title: "##{@tag.name} - Influencers Paraguay | #{SITE_NAME}",
      description: "Explora #{total_profiles} influencers paraguayos etiquetados con ##{@tag.name}. Rankings actualizados, análisis de engagement y métricas detalladas de Instagram.",
      keywords: "#{@tag.name} Paraguay, hashtag #{@tag.name}, influencers #{@tag.name}, #{KEYWORDS}",
      canonical: tag_url(@tag),
      og: {
        title: "##{@tag.name} - Influencers Paraguay",
        description: "#{total_profiles} influencers paraguayos destacados en la categoría #{tag_name}",
        type: 'website',
        url: tag_url(@tag),
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "##{@tag.name} - Influencers Paraguay",
        description: "#{total_profiles} influencers paraguayos destacados en #{tag_name}"
      },
      alternate: {
        'es-PY' => tag_url(@tag)
      }
    )
  end
end
