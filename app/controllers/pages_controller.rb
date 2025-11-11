# frozen_string_literal: true

class PagesController < ApplicationController
  include SeoConcern

  def about
    set_about_meta_tags
  end

  private

  def set_about_meta_tags
    set_meta_tags(
      title: "Acerca de Nosotros | #{SITE_NAME}",
      description: "Conoce más sobre #{SITE_NAME}, la plataforma líder de análisis y rankings de influencers en Paraguay. Conectando marcas con los mejores creadores de contenido.",
      keywords: "acerca de, sobre nosotros, equipo, #{KEYWORDS}",
      canonical: about_url,
      og: {
        title: "Acerca de #{SITE_NAME}",
        description: "La plataforma líder de análisis y rankings de influencers en Paraguay",
        type: 'website',
        url: about_url,
        image: OG_IMAGE_URL,
        site_name: SITE_NAME,
        locale: 'es_PY'
      },
      twitter: {
        card: 'summary_large_image',
        site: TWITTER_HANDLE,
        title: "Acerca de #{SITE_NAME}",
        description: "La plataforma líder de análisis y rankings de influencers en Paraguay"
      }
    )
  end
end

