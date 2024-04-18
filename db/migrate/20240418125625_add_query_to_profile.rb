# frozen_string_literal: true

class AddQueryToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :query, :text
  end
end
