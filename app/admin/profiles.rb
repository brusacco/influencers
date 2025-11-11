# frozen_string_literal: true

ActiveAdmin.register Profile do
  permit_params :username,
                :data,
                :country,
                :country_string,
                :profile_type,
                :query,
                :uid,
                :followers,
                :following,
                :profile_pic_url,
                :is_business_account,
                :is_professional_account,
                :business_category_name,
                :category_enum,
                :category_name,
                :is_private,
                :is_verified,
                :full_name,
                :biography,
                :is_joined_recently,
                :is_embeds_disabled,
                :profile_pic_url_hd,
                :enabled,
                tag_list: []

  #------------------------------------------------------------------
  config.batch_actions = true
  scoped_collection_action :scoped_collection_destroy

  scoped_collection_action :scoped_collection_update,
                           form: lambda {
                                   {
                                     country_string: 'text',
                                     profile_type: Profile.profile_types.map do |role|
                                                     [role.first.titleize, role.first]
                                                   end,
                                     enabled: [['Enabled', true], ['Disabled', false]],
                                     tag_list: ActsAsTaggableOn::Tag.pluck(:name)
                                   }
                                 }
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

  #------------------------------------------------------------------
  # UPDATE_PROFILE
  #------------------------------------------------------------------
  action_item :update_profile, only: :show do
    link_to 'Update Profile',
            update_profile_admin_profile_path(profile.id),
            method: :put,
            data: { confirm: 'Are you sure?' }
  end

  member_action :update_profile, method: :put do
    profile = Profile.find(params[:id])
    profile.update_profile

    flash[:notice] = 'Profile Updated successfully'
    redirect_to admin_profile_path, notice: 'Profile Updated successfully'
  end
  #------------------------------------------------------------------

  filter :username
  filter :country_string, as: :select, collection: %w[Paraguay Otros]
  filter :profile_type, as: :select, collection: Profile.profile_types.map
  filter :category_name, as: :select, collection: Profile.where.not(category_name: nil).pluck(:category_name).uniq.sort
  filter :enabled, as: :select, collection: [['Enabled', true], ['Disabled', false]]
  filter :is_private
  filter :is_business_account
  filter :followers
  filter :biography
  filter :data

  scope :all, group: :country
  scope :paraguayos, group: :country
  scope :otros, group: :country
  scope :no_country, group: :country

  scope :enabled, group: :status
  scope :disabled, group: :status

  scope :no_profile_type

  index do
    selectable_column
    column :id
    column 'Avatar' do |profile|
      if profile.avatar.attached?
        link_to image_tag(rails_blob_url(profile.avatar), size: 100),
                profile_path(profile),
                target: '_blank',
                rel: 'noopener'
      end
    end
    column 'Username' do |profile|
      link_to profile.username, "https://www.instagram.com/#{profile.username}", target: '_blank', rel: 'noopener'
    end
    column :biography
    column :profile_type
    column :followers
    column :enabled do |profile|
      status_tag profile.enabled, class: (profile.enabled ? 'yes' : 'no')
    end
    # column :engagement_rate
    # column :total_interactions_count
    column :country_string
    # column :category_enum
    column :category_name
    column :tag_list

    actions
  end

  form do |f|
    f.inputs 'Profile Details' do
      f.input :username
      f.input :profile_type
      f.input :enabled, as: :boolean, label: 'Enabled (Show/Track profile)'
      f.input :followers
      f.input :following
      f.input :profile_pic_url
      f.input :is_business_account, as: :boolean
      f.input :is_professional_account, as: :boolean
      f.input :business_category_name
      f.input :category_enum
      f.input :category_name
      f.input :tag_list, as: :check_boxes, collection: ActsAsTaggableOn::Tag.pluck(:name)
      f.input :is_private, as: :boolean
      f.input :is_verified, as: :boolean
      f.input :full_name
      f.input :biography
      f.input :is_joined_recently, as: :boolean
      f.input :is_embeds_disabled, as: :boolean
      f.input :country_string,
              as: :select,
              collection: %w[Paraguay Otros],
              input_html: { value: 'Paraguay' },
              selected: 'Paraguay'
      f.input :profile_pic_url_hd
      f.input :query
      f.input :uid
    end
    f.actions
  end
end
