# frozen_string_literal: true

ActiveAdmin.register InstagramPost do
  menu parent: 'Posts', label: 'Instagram Posts'
  permit_params :data,
                :profile_id,
                :shortcode,
                :likes_count,
                :comments_count,
                :video_view_count,
                :product_type,
                :media,
                :caption,
                :url,
                :posted_at

  filter :shortcode

  index do
    selectable_column
    column :id
    column :shortcode
    column :posted_at
    column :caption
    column :likes_count
    column :comments_count
    column :video_view_count
    column :product_type
    column :media
    actions
  end
end
