# frozen_string_literal: true

class AddImageUrlToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :profile_pic_url, :text
  end
end
