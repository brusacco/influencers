# frozen_string_literal: true

class AddIidToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :uid, :string
  end
end
