# frozen_string_literal: true

class AddDataToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :followers, :integer, default: 0
    add_column :profiles, :following, :integer, default: 0
    add_column :profiles, :avatar, :text
  end
end
