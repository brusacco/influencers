# frozen_string_literal: true

class AddIndexToInstagramPost < ActiveRecord::Migration[7.0]
  def change
    add_index :instagram_posts, :posted_at
    add_index :instagram_posts, %i[profile_id posted_at]
  end
end
