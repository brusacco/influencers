# frozen_string_literal: true

module InstagramServices
  class UpdateProfileData < ApplicationService
    def initialize(data)
      @data = data
    end

    def call
      return handle_error('Null data') if @data.nil?

      user = @data['graphql']['user']
      response = {
        followers: user['edge_followed_by']['count'],
        following: user['edge_follow']['count'],
        profile_pic_url: user['profile_pic_url'],
        profile_pic_url_hd: user['profile_pic_url_hd'],
        is_business_account: user['is_business_account'],
        is_professional_account: user['is_professional_account'],
        business_category_name: user['business_category_name'],
        category_enum: user['category_enum'],
        category_name: user['category_name'],
        is_private: user['is_private'],
        is_verified: user['is_verified'],
        full_name: user['full_name'],
        biography: user['biography'],
        is_joined_recently: user['is_joined_recently'],
        is_embeds_disabled: user['is_embeds_disabled']
      }
      handle_success(response)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
