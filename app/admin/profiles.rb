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

  form do |f|
    f.inputs 'Profile Details' do
      f.input :username
      f.input :followers
      f.input :following
      f.input :avatar
      f.input :profile_pic_url
      f.input :is_business_account, as: :boolean
      f.input :is_professional_account, as: :boolean
      f.input :business_category_name
      f.input :category_enum
      f.input :category_name
      f.input :is_private, as: :boolean
      f.input :is_verified, as: :boolean
      f.input :full_name
      f.input :biography
      f.input :is_joined_recently, as: :boolean
      f.input :is_embeds_disabled, as: :boolean
      f.input :country_string
      f.input :profile_pic_url_hd
    end
    f.actions
  end
end
