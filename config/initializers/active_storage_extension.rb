# frozen_string_literal: true

module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern
  included do
    def self.ransackable_attributes(_auth_object = nil)
      %w[blob_id created_at id name record_id record_type]
    end
  end
end

Rails.configuration.to_prepare do
  ActiveSupport.on_load(:active_storage_attachment) { include ActiveStorageAttachmentExtension }
end
