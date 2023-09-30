# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :username
      t.text :data

      t.timestamps
    end
    add_index :profiles, :username, unique: true
  end
end
