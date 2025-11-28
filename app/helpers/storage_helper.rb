# frozen_string_literal: true

# app/helpers/storage_helper.rb

Rails.application.routes.default_url_options[:host] = 'localhost:9000'

module StorageHelper
  def direct_blob_url(blob)
    return unless blob&.key

    # Always use direct blob URLs for better caching
    prefix = '/blob_files'
    key = blob.key
    path = "#{prefix}/#{key[0..1]}/#{key[2..3]}/#{key}"
    URI.join(root_url, path).to_s
  end
end
