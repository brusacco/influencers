# frozen_string_literal: true

# app/helpers/storage_helper.rb

module StorageHelper
  def direct_blob_url(blob)
    return unless blob&.key

    if Rails.env.production?
      prefix = '/blob_files'
      key = blob.key
      path = "#{prefix}/#{key[0..1]}/#{key[2..3]}/#{key}"
      URI.join(root_url, path).to_s
    else
      # fallback to normal Rails route in dev
      Rails.application.routes.url_helpers.url_for(blob)
    end
  end
end
