# frozen_string_literal: true

class AddData2ToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :is_business_account, :boolean, default: false
    add_column :profiles, :is_professional_account, :boolean, default: false
    add_column :profiles, :business_category_name, :string
    add_column :profiles, :category_enum, :string
    add_column :profiles, :category_name, :string
    add_column :profiles, :is_private, :boolean, default: false
    add_column :profiles, :is_verified, :boolean, default: false
    add_column :profiles, :full_name, :string
    add_column :profiles, :biography, :text
    add_column :profiles, :is_joined_recently, :boolean, default: false
    add_column :profiles, :is_embeds_disabled, :boolean, default: false
  end
end
