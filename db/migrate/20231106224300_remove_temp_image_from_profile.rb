# frozen_string_literal: true

class RemoveTempImageFromProfile < ActiveRecord::Migration[7.0]
  def change
    remove_column :profiles, :temp_image, :string
  end
end
