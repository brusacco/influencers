# frozen_string_literal: true

class RemoveTempImageFromInstagramPost < ActiveRecord::Migration[7.0]
  def change
    remove_column :instagram_posts, :temp_image, :string
  end
end
