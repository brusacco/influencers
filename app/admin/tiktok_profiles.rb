# frozen_string_literal: true

ActiveAdmin.register TiktokProfile do
  menu parent: 'Profiles'
  permit_params :username,
                :unique_id,
                :nickname,
                :signature,
                :user_id,
                :sec_uid,
                :followers,
                :following,
                :hearts,
                :video_count,
                :digg_count,
                :friend_count,
                :verified,
                :is_private,
                :is_under_age_18,
                :is_embed_banned,
                :commerce_user,
                :enabled,
                :avatar_larger,
                :avatar_medium,
                :avatar_thumb,
                :country_string,
                :profile_type,
                :query,
                :data, # Internal field - not shown in forms but needed for programmatic updates
                tag_list: []

  filter :username
  filter :unique_id
  filter :nickname
  filter :country_string, as: :select, collection: %w[Paraguay Otros]
  filter :profile_type, as: :select, collection: TiktokProfile.profile_types.map
  filter :enabled, as: :select, collection: [['Enabled', true], ['Disabled', false]]
  filter :is_private
  filter :verified
  filter :followers
  filter :hearts
  filter :video_count
  filter :created_at
  filter :updated_at

  scope :all, group: :country
  scope :paraguayos, group: :country
  scope :otros, group: :country
  scope :no_country, group: :country

  scope :enabled, group: :status
  scope :disabled, group: :status

  scope :micro, group: :size
  scope :macro, group: :size

  #------------------------------------------------------------------
  # UPDATE_PROFILE
  #------------------------------------------------------------------
  batch_action :update_profile do |ids|
    batch_action_collection.find(ids).each do |profile|
      profile.update_profile
    end
    # Preserve the current query parameters (filters)
    current_params = request.query_parameters

    # Redirect to the collection path with the preserved query parameters
    redirect_to collection_path(current_params), alert: 'The profiles have been updated.'
  end

  action_item :update_profile, only: :show do
    link_to 'Update Profile',
            update_profile_admin_tiktok_profile_path(tiktok_profile.id),
            method: :put,
            data: { confirm: 'Are you sure?' }
  end

  member_action :update_profile, method: :put do
    profile = TiktokProfile.find(params[:id])
    profile.update_profile

    flash[:notice] = 'Profile Updated successfully'
    redirect_to admin_tiktok_profile_path, notice: 'Profile Updated successfully'
  end

  action_item :update_posts, only: :show do
    link_to 'Update Posts',
            update_posts_admin_tiktok_profile_path(tiktok_profile.id),
            method: :put,
            data: { confirm: 'This will fetch and save posts from TikTok. Continue?' }
  end

  member_action :update_posts, method: :put do
    profile = TiktokProfile.find(params[:id])
    result = profile.update_posts

    if result[:success]
      notice = "Posts updated successfully! Created: #{result[:posts_created]}, Updated: #{result[:posts_updated]}"
      notice += " Errors: #{result[:errors].join(', ')}" if result[:errors].any?
      flash[:notice] = notice
    else
      flash[:alert] = "Error: #{result[:error]}"
    end

    redirect_to admin_tiktok_profile_path
  end
  #------------------------------------------------------------------

  index do
    selectable_column
    column :id
    column 'Avatar' do |profile|
      if profile.avatar_thumb.present?
        link_to image_tag(profile.avatar_thumb, size: 100),
                "https://www.tiktok.com/@#{profile.display_username}",
                target: '_blank',
                rel: 'noopener'
      end
    end
    column 'Username' do |profile|
      link_to profile.display_username,
              "https://www.tiktok.com/@#{profile.display_username}",
              target: '_blank',
              rel: 'noopener'
    end
    column :nickname
    column :signature
    column :followers
    column :following
    column :hearts
    column :video_count
    column :verified do |profile|
      status_tag profile.verified, class: (profile.verified ? 'yes' : 'no')
    end
    column :is_private do |profile|
      status_tag profile.is_private, class: (profile.is_private ? 'yes' : 'no')
    end
    column :enabled do |profile|
      status_tag profile.enabled, class: (profile.enabled ? 'yes' : 'no')
    end
    column :country_string
    column :profile_type
    # column :created_at
    #column :updated_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :username
      row :unique_id
      row 'Avatar' do |profile|
        if profile.avatar_larger.present?
          image_tag profile.avatar_larger, size: 200
        end
      end
      row :nickname
      row :signature
      row :followers
      row :following
      row :hearts
      row :video_count
      row :digg_count
      row :friend_count
      row :verified
      row :is_private
      row :is_under_age_18
      row :is_embed_banned
      row :commerce_user
      row :enabled
      row :user_id
      row :sec_uid
      row :avatar_larger
      row :avatar_medium
      row :avatar_thumb
      row :country_string
      row :profile_type
      row :query
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'TikTok Profile Details' do
      f.input :username
      f.input :unique_id
      f.input :nickname
      f.input :signature
      f.input :followers
      f.input :following
      f.input :hearts
      f.input :video_count
      f.input :verified, as: :boolean
      f.input :is_private, as: :boolean
      f.input :enabled, as: :boolean, label: 'Enabled (Show/Track profile)'
      f.input :country_string,
              as: :select,
              collection: %w[Paraguay Otros],
              input_html: { value: 'Paraguay' },
              selected: 'Paraguay'
      f.input :profile_type
      f.input :avatar_larger
      f.input :avatar_medium
      f.input :avatar_thumb
      f.input :user_id
      f.input :sec_uid
      f.input :query
    end
    f.actions
  end
end

