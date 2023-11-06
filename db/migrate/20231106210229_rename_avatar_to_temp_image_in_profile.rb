# frozen_string_literal: true

class RenameAvatarToTempImageInProfile < ActiveRecord::Migration[6.0]
  def change
    rename_column :profiles, :avatar, :temp_image
  end
end
