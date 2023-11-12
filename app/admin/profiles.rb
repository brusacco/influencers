# frozen_string_literal: true

ActiveAdmin.register Profile do
  permit_params :username, :data, :country, :country_string, :profile_type

  #------------------------------------------------------------------
  config.batch_actions = true
  scoped_collection_action :scoped_collection_destroy

  scoped_collection_action :scoped_collection_update,
                           form: lambda {
                                   {
                                     country_string: 'text',
                                     profile_type: Profile.profile_types.map
                                   }
                                 }
  #------------------------------------------------------------------

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
  filter :category_name
  filter :is_private
  filter :is_business_account
  filter :followers
  filter :biography
  filter :data

  scope :all
  scope :paraguayos
  scope :otros
  scope :no_country

  index do
    selectable_column
    column :id
    column 'Avatar' do |profile|
      image_tag profile.avatar, size: 100 if profile.avatar.attached?
    end
    column 'Username' do |profile|
      link_to profile.username, "https://www.instagram.com/#{profile.username}", target: '_blank', rel: 'noopener'
    end
    column :biography
    column :followers
    column :engagement_rate
    column :total_interactions_count
    column :country_string
    column :is_business_account
    column :category_enum
    column :category_name

    actions
  end

  form do |f|
    f.inputs 'Profile Details' do
      f.input :username
      f.input :profile_type, as: :select, collection: Profile.profile_types
      f.input :followers
      f.input :following
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
