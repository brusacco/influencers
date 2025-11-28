# frozen_string_literal: true

ActiveAdmin.register TiktokPost do
  menu parent: 'Posts', label: 'TikTok Posts'

  permit_params :data,
                :tiktok_profile_id,
                :tiktok_post_id,
                :desc,
                :posted_at,
                :likes_count,
                :comments_count,
                :play_count,
                :shares_count,
                :collects_count,
                :total_count,
                :video_url,
                :cover_url,
                :dynamic_cover_url,
                :video_duration,
                :video_definition,
                :music_title,
                :music_author,
                :music_play_url

  filter :tiktok_post_id
  filter :tiktok_profile
  filter :desc
  filter :posted_at
  filter :likes_count
  filter :comments_count
  filter :play_count
  filter :created_at
  filter :updated_at

  scope :all, default: true
  scope :a_day_ago
  scope :a_week_ago
  scope :a_month_ago

  index do
    selectable_column
    column :id
    column 'Cover' do |post|
      if post.cover_url.present?
        link_to image_tag(post.cover_url, size: 100),
                "https://www.tiktok.com/@#{post.tiktok_profile&.display_username}/video/#{post.tiktok_post_id}",
                target: '_blank',
                rel: 'noopener'
      end
    end
    column :tiktok_post_id do |post|
      link_to post.tiktok_post_id,
              "https://www.tiktok.com/@#{post.tiktok_profile&.display_username}/video/#{post.tiktok_post_id}",
              target: '_blank',
              rel: 'noopener'
    end
    column :tiktok_profile do |post|
      link_to post.tiktok_profile&.display_username,
              admin_tiktok_profile_path(post.tiktok_profile),
              target: '_blank' if post.tiktok_profile
    end
    column :desc do |post|
      truncate(post.desc, length: 50) if post.desc.present?
    end
    column :posted_at
    column :likes_count
    column :comments_count
    column :play_count
    column :shares_count
    column :total_count
    actions
  end

  show do
    attributes_table do
      row :id
      row :tiktok_post_id do |post|
        link_to post.tiktok_post_id,
                "https://www.tiktok.com/@#{post.tiktok_profile&.display_username}/video/#{post.tiktok_post_id}",
                target: '_blank',
                rel: 'noopener'
      end
      row :tiktok_profile do |post|
        link_to post.tiktok_profile&.display_username,
                admin_tiktok_profile_path(post.tiktok_profile) if post.tiktok_profile
      end
      row 'Cover' do |post|
        if post.cover_url.present?
          image_tag post.cover_url, size: 300
        end
      end
      row 'Dynamic Cover' do |post|
        if post.dynamic_cover_url.present?
          image_tag post.dynamic_cover_url, size: 300
        end
      end
      row :desc
      row :posted_at
      row :likes_count
      row :comments_count
      row :play_count
      row :shares_count
      row :collects_count
      row :total_count
      row :video_url do |post|
        link_to 'View Video', post.video_url, target: '_blank', rel: 'noopener' if post.video_url.present?
      end
      row :video_duration
      row :video_definition
      row :music_title
      row :music_author
      row :music_play_url do |post|
        link_to 'Play Music', post.music_play_url, target: '_blank', rel: 'noopener' if post.music_play_url.present?
      end
      row :cover_url
      row :dynamic_cover_url
      row :created_at
      row :updated_at
      row :data do |post|
        pre JSON.pretty_generate(post.data) if post.data.present?
      end
    end
  end

  form do |f|
    f.inputs 'TikTok Post Details' do
      f.input :tiktok_profile
      f.input :tiktok_post_id
      f.input :desc
      f.input :posted_at
      f.input :likes_count
      f.input :comments_count
      f.input :play_count
      f.input :shares_count
      f.input :collects_count
      f.input :total_count
      f.input :video_url
      f.input :cover_url
      f.input :dynamic_cover_url
      f.input :video_duration
      f.input :video_definition
      f.input :music_title
      f.input :music_author
      f.input :music_play_url
      f.input :data, as: :text, input_html: { rows: 20, style: 'font-family: monospace;' }
    end
    f.actions
  end
end

