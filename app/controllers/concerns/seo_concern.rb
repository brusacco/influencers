# frozen_string_literal: true

# SEO Concern
# Handles all SEO meta tags configuration for different pages
module SeoConcern
  extend ActiveSupport::Concern

  # Homepage SEO
  def set_homepage_meta_tags
    set_meta_tags(
      title: "#{SITE_NAME} - #{SITE_TAGLINE}",
      description: DESCRIPTION,
      keywords: KEYWORDS,
      canonical: root_url,
      og: {
        title: "#{SITE_NAME} - #{SITE_TAGLINE}",
        description: DESCRIPTION,
        type: 'website',
        url: root_url,
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "#{SITE_NAME} - #{SITE_TAGLINE}",
        description: DESCRIPTION,
        image: OG_IMAGE_URL
      },
      alternate: {
        'es-PY' => root_url
      }
    )
  end

  # Profiles Index SEO
  def set_profiles_index_meta_tags
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

  # Profile Detail SEO
  def set_profile_meta_tags(profile)
    followers_text = profile.followers.present? ? "#{view_context.number_to_human(profile.followers)} seguidores" : "influencer"
    profile_description = profile.biography.presence || 
      "Perfil de #{profile.full_name} (@#{profile.username}) - #{followers_text}. Descubre métricas, engagement rate y análisis completo de uno de los influencers más destacados de Paraguay."
    
    profile_keywords = build_profile_keywords(profile)

    set_meta_tags(
      title: "#{profile.full_name} (@#{profile.username}) - Influencer #{profile.profile_type&.capitalize} | #{SITE_NAME}",
      description: profile_description.truncate(155),
      keywords: "#{profile_keywords}, Instagram Paraguay, #{KEYWORDS}",
      canonical: profile_url(profile),
      og: {
        title: "#{profile.full_name} (@#{profile.username})",
        description: profile_description.truncate(200),
        type: 'profile',
        url: profile_url(profile),
        image: profile.avatar.attached? ? direct_blob_url(profile.avatar) : OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY',
        profile: {
          username: profile.username,
          first_name: profile.full_name.to_s.split.first.to_s,
          last_name: profile.full_name.to_s.split.last.to_s
        }
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "#{profile.full_name} (@#{profile.username})",
        description: profile_description.truncate(200),
        image: profile.avatar.attached? ? direct_blob_url(profile.avatar) : OG_IMAGE_URL
      },
      article: {
        published_time: profile.created_at.iso8601,
        modified_time: profile.updated_at.iso8601,
        tag: profile.tags.pluck(:name)
      }
    )
  end

  # Category Page SEO
  def set_category_meta_tags(category, total_profiles)
    category_name = category.capitalize

    set_meta_tags(
      title: "Influencers #{category_name} Paraguay - Top #{total_profiles} Perfiles | #{SITE_NAME}",
      description: "Descubre los mejores influencers de #{category_name} en Paraguay. Ranking actualizado con análisis de seguidores, engagement y métricas de rendimiento. #{total_profiles}+ perfiles verificados.",
      keywords: "influencers #{category} Paraguay, #{category_name} Paraguay Instagram, mejores #{category} paraguayos, ranking #{category}, #{KEYWORDS}",
      canonical: category_show_url(category),
      og: {
        title: "Top Influencers #{category_name} en Paraguay",
        description: "Los #{total_profiles} influencers más destacados de #{category_name} en Paraguay con métricas completas",
        type: 'website',
        url: category_show_url(category),
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
        'es-PY' => category_show_url(category)
      }
    )
  end

  # Tag Page SEO
  def set_tag_meta_tags(tag, total_profiles)
    tag_name = tag.name.titleize

    set_meta_tags(
      title: "##{tag.name} - Influencers Paraguay | #{SITE_NAME}",
      description: "Explora #{total_profiles} influencers paraguayos etiquetados con ##{tag.name}. Rankings actualizados, análisis de engagement y métricas detalladas de Instagram.",
      keywords: "#{tag.name} Paraguay, hashtag #{tag.name}, influencers #{tag.name}, #{KEYWORDS}",
      canonical: tag_url(tag),
      og: {
        title: "##{tag.name} - Influencers Paraguay",
        description: "#{total_profiles} influencers paraguayos destacados en la categoría #{tag_name}",
        type: 'website',
        url: tag_url(tag),
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "##{tag.name} - Influencers Paraguay",
        description: "#{total_profiles} influencers paraguayos destacados en #{tag_name}"
      },
      alternate: {
        'es-PY' => tag_url(tag)
      }
    )
  end

  private

  # Build profile keywords from various attributes
  def build_profile_keywords(profile)
    keywords = ["#{profile.username}", "#{profile.full_name}", "influencer Paraguay"]
    keywords << profile.tags.pluck(:name).join(', ') if profile.tags.any?
    keywords << profile.profile_type if profile.profile_type.present?
    keywords.join(', ')
  end
end

