# frozen_string_literal: true

class AddTotalToInstagramPost < ActiveRecord::Migration[7.0]
  def change
    add_column :instagram_posts, :total_count, :integer, default: 0
  end
end
