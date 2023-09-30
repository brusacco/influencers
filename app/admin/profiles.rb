# frozen_string_literal: true

ActiveAdmin.register Profile do
  permit_params :username, :data, :country, :country_string

  filter :username
  filter :category_name
  filter :is_private
  filter :is_business_account
  filter :followers
  filter :biography
  filter :data

  scope :all
  scope :paraguayos
  scope :no_country

  index do
    selectable_column
    column :id
    column 'Avatar' do |profile|
      image_tag "data:image/jpeg;base64,#{profile.avatar}", size: 100
    end
    column 'Username' do |profile|
      link_to profile.username, "https://www.instagram.com/#{profile.username}", target: '_blank', rel: 'noopener'
    end
    column :biography
    column :followers
    column :country_string
    column :is_business_account
    column :category_enum
    column :category_name

    actions
  end
end
