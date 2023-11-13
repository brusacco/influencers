# frozen_string_literal: true

class InstagramCollaboration < ApplicationRecord
  belongs_to :instagram_post, touch: true
  belongs_to :collaborator, class_name: 'Profile'
  belongs_to :collaborated, class_name: 'Profile'

  def self.ransackable_attributes(_auth_object = nil)
    %w[collaborated_id collaborator_id created_at id instagram_post_id posted_at updated_at]
  end
end
