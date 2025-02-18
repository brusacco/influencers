# frozen_string_literal: true

module InstagramServices
  class UpdateProfileData < ApplicationService
    def initialize(data)
      @data = data
    end

    def call
      return handle_error('Null data') if @data.nil?

      user = @data['data']['user']
      response = {
        followers: user['follower_count'],
        following: user['following_count'],
        profile_pic_url: user['profile_pic_url'],
        profile_pic_url_hd: user['hd_profile_pic_url_info']['url'] || nil,
        is_business_account: user['is_business'] || nil,
        is_professional_account: user['is_professional_account'] || nil,
        business_category_name: user['business_category_name'] || nil,
        category_enum: user['category_enum'] || nil,
        category_name: user['category'],
        is_private: user['is_private'],
        is_verified: user['is_verified'],
        full_name: user['full_name'],
        biography: user['biography'],
        is_joined_recently: user['is_joined_recently'] || nil,
        is_embeds_disabled: user['is_embeds_disabled'],
        uid: user['id']
      }
      handle_success(response)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
