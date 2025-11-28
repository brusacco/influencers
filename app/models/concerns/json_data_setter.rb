# frozen_string_literal: true

# Concern to handle JSON data field setters that accept both Hash and JSON string inputs
# Used by models that store API responses in a JSON field
module JsonDataSetter
  extend ActiveSupport::Concern

  included do
    # Custom setter for data field to handle both Hash and JSON string inputs
    # This handles data from Active Admin forms (JSON strings) and API responses (Hashes)
    def data=(value)
      case value
      when Hash
        super(value)
      when String
        # Handle empty strings or whitespace-only strings
        if value.blank? || value.strip.empty?
          super({})
        else
          # Parse JSON string
          parsed = JSON.parse(value.strip)
          super(parsed.is_a?(Hash) ? parsed : {})
        end
      else
        # Handle nil or any other type - default to empty hash
        super({})
      end
    rescue JSON::ParserError => e
      # If JSON parsing fails, log and default to empty hash
      Rails.logger.warn("Failed to parse data JSON: #{e.message}") if Rails.logger
      super({})
    end
  end
end

