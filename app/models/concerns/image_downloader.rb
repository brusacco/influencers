# frozen_string_literal: true

# Concern to handle downloading and attaching images from URLs
# Used by models that need to save images locally using ActiveStorage
module ImageDownloader
  extend ActiveSupport::Concern

  # Download image from URL and attach to specified ActiveStorage attachment
  # @param url [String] URL of the image to download
  # @param attachment_name [Symbol] Name of the ActiveStorage attachment (e.g., :avatar, :cover)
  # @param filename [String] Filename for the attachment
  # @param placeholder_url [String, nil] Optional placeholder URL if download fails
  # @return [Boolean] true if attachment was successful, false otherwise
  def download_and_attach_image(url, attachment_name, filename, placeholder_url: nil)
    attachment = send(attachment_name)
    return false if attachment.attached?
    return false if url.blank?

    begin
      response = HTTParty.get(url)
      send(attachment_name).attach(
        io: StringIO.new(response.body),
        filename: filename
      )
      true
    rescue StandardError => e
      Rails.logger.warn("Failed to download image from #{url}: #{e.message}") if Rails.logger
      
      # Try placeholder if provided
      return false unless placeholder_url

      begin
        placeholder_response = HTTParty.get(placeholder_url)
        send(attachment_name).attach(
          io: StringIO.new(placeholder_response.body),
          filename: 'placeholder.jpg'
        )
        true
      rescue StandardError => placeholder_error
        Rails.logger.warn("Failed to download placeholder image: #{placeholder_error.message}") if Rails.logger
        false
      end
    end
  end
end

