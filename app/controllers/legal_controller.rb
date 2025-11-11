# frozen_string_literal: true

class LegalController < ApplicationController
  def privacy
    set_privacy_meta_tags
  end

  def terms
    set_terms_meta_tags
  end

  private

  def set_privacy_meta_tags
    set_meta_tags(
      title: "Política de Privacidad | #{SITE_NAME}",
      description: "Política de privacidad de #{SITE_NAME}. Conoce cómo protegemos y manejamos tu información personal.",
      robots: 'index, follow'
    )
  end

  def set_terms_meta_tags
    set_meta_tags(
      title: "Términos y Condiciones | #{SITE_NAME}",
      description: "Términos y condiciones de uso de #{SITE_NAME}. Lee nuestras políticas y condiciones de servicio.",
      robots: 'index, follow'
    )
  end
end

