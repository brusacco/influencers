# frozen_string_literal: true

ActiveAdmin.register InstagramPost do
  permit_params :data,
                :profile_id,
                :image,
                :shortcode,
                :likes_count,
                :comments_count,
                :video_view_count,
                :product_type,
                :media,
                :caption,
                :url,
                :posted_at

  index do
    selectable_column
    column :id
    column 'Image' do |post|
      image_tag "data:image/jpeg;base64,#{post.image}", size: 50
    end
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
