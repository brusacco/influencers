# frozen_string_literal: true

STOP_WORDS = Rails.root.join('stop-words.txt').readlines.map(&:strip).freeze

# SEO Constants - Optimized for Paraguay Market
SITE_NAME = 'Influencers.com.py'
SITE_TAGLINE = 'Plataforma Líder de Influencer Marketing en Paraguay'

# Default Meta Tags
DESCRIPTION = 'Descubre los influencers más destacados de Paraguay. Análisis completo de seguidores, engagement y métricas de Instagram. Conecta con los mejores creadores de contenido para tus campañas de marketing digital.'
KEYWORDS = 'influencer marketing Paraguay, influencers paraguayos, creadores de contenido Paraguay, Instagram Paraguay, marketing digital Paraguay, engagement rate, análisis de influencers, campañas digitales'

# Open Graph Default Image
OG_IMAGE_URL = 'https://influencers.com.py/og-image.png' # TODO: Replace with actual URL

# Twitter Handle
TWITTER_HANDLE = '@influencerspy' # TODO: Replace with actual handle

# Structured Data
ORGANIZATION_SCHEMA = {
  '@context' => 'https://schema.org',
  '@type' => 'Organization',
  'name' => SITE_NAME,
  'url' => 'https://influencers.com.py',
  'logo' => 'https://influencers.com.py/logo.png',
  'description' => DESCRIPTION,
  'address' => {
    '@type' => 'PostalAddress',
    'addressCountry' => 'PY'
  },
  'sameAs' => [
    'https://www.instagram.com/influencerspy',
    'https://www.facebook.com/influencerspy'
  ]
}.freeze
