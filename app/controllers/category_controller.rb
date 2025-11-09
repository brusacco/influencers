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

    @profiles = Profile.paraguayos.where(profile_type: @category).order(followers: :desc).limit(40)
    @profiles_interactions = Profile.paraguayos
                                    .where(profile_type: @category)
                                    .order(total_interactions_count: :desc)
                                    .limit(20)
    @profiles_video_views = Profile.paraguayos
                                   .where(profile_type: @category)
                                   .order(total_video_view_count: :desc)
                                   .limit(20)

    # SEO Meta Tags - Category Page
    category_name = @category.capitalize
    total_profiles = @profiles.size
    
    set_meta_tags(
      title: "Influencers #{category_name} Paraguay - Top #{total_profiles} Perfiles | #{SITE_NAME}",
      description: "Descubre los mejores influencers de #{category_name} en Paraguay. Ranking actualizado con análisis de seguidores, engagement y métricas de rendimiento. #{total_profiles}+ perfiles verificados.",
      keywords: "influencers #{@category} Paraguay, #{category_name} Paraguay Instagram, mejores #{@category} paraguayos, ranking #{@category}, #{KEYWORDS}",
      canonical: category_show_url(@category),
      og: {
        title: "Top Influencers #{category_name} en Paraguay",
        description: "Los #{total_profiles} influencers más destacados de #{category_name} en Paraguay con métricas completas",
        type: 'website',
        url: category_show_url(@category),
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "Top Influencers #{category_name} en Paraguay",
        description: "Los #{total_profiles} influencers más destacados de #{category_name}"
      },
      alternate: {
        'es-PY' => category_show_url(@category)
      }
    )
  end
end
