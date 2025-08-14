# frozen_string_literal: true

class Tag < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name taggings_count updated_at]
  end
end
