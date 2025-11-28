# frozen_string_literal: true

# Controller to serve ActiveStorage blobs directly from filesystem
# This mimics how nginx/apache serves files in production
class BlobFilesController < ApplicationController
  # Serve blob files directly from filesystem
  # Route: /blob_files/:dir1/:dir2/:key
  def show
    dir1 = params[:dir1]
    dir2 = params[:dir2]
    key = params[:key]

    # Construct the file path based on ActiveStorage's directory structure
    storage_path = Rails.root.join('storage', dir1, dir2, key)

    # Security: Ensure the path is within the storage directory
    unless storage_path.to_s.start_with?(Rails.root.join('storage').to_s)
      head :forbidden
      return
    end

    # Check if file exists
    unless File.exist?(storage_path)
      head :not_found
      return
    end

    # Try to get content type from ActiveStorage blob record
    # The key parameter already contains the full blob key
    blob = ActiveStorage::Blob.find_by(key: key)
    content_type = if blob&.content_type.present?
                     blob.content_type
                   elsif File.extname(key).present?
                     # Fallback to MIME type from extension
                     Mime::Type.lookup_by_extension(File.extname(key).delete_prefix('.')) || 'application/octet-stream'
                   else
                     # Final fallback
                     'application/octet-stream'
                   end

    # Set appropriate headers
    response.headers['Content-Type'] = content_type.to_s
    response.headers['Cache-Control'] = 'public, max-age=31536000' # Cache for 1 year
    response.headers['X-Content-Type-Options'] = 'nosniff'

    # Send file
    send_file storage_path, disposition: 'inline', type: content_type
  end
end

