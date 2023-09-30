class AddImageHdToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :profile_pic_url_hd, :text
  end
end
