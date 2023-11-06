class RenameImageFieldToTempImageInInstagramPost < ActiveRecord::Migration[6.0]
  def change
    rename_column :instagram_posts, :image, :temp_image
  end
end
