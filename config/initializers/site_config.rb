# frozen_string_literal: true

# Site Configuration Constants
# These constants are used throughout the application for branding, SEO, and limits
module SiteConfig
  # Branding & SEO
  SITE_NAME = "Influencers.com.py"
  SITE_TAGLINE = "La plataforma líder de influencer marketing en Paraguay"
  DESCRIPTION = "Descubre los influencers más destacados de Paraguay. Análisis completo de métricas, engagement y colaboraciones de más de 500 creadores de contenido paraguayos."
  KEYWORDS = "influencers Paraguay, Instagram Paraguay, marketing digital Paraguay, creadores contenido Paraguay"
  OG_IMAGE_URL = "https://influencers.com.py/og-image.png"
  TWITTER_HANDLE = "@influencerspy"
  
  # Query Limits
  TOP_PROFILES_LIMIT = 40
  ENGAGEMENT_PROFILES_LIMIT = 20
  VIDEO_VIEWS_PROFILES_LIMIT = 20
  RELATED_PROFILES_LIMIT = 12
  RECENT_POSTS_LIMIT = 20
  MENTIONS_LIMIT = 20
  COLLABORATIONS_LIMIT = 12
  INACTIVE_PROFILES_LIMIT = 40
  
  # Posts Limits
  POPULAR_POSTS_LIMIT = 20
  WEEKLY_POSTS_LIMIT = 48
  
  # Cache Durations
  CACHE_SHORT_DURATION = 30.minutes
  CACHE_MEDIUM_DURATION = 60.minutes
end

# Make constants available globally
Rails.application.config.to_prepare do
  Object.include SiteConfig
end

