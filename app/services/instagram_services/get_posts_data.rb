# frozen_string_literal: true

module InstagramServices
  class GetPostsData < ApplicationService
    def initialize(profile)
      @profile = profile
    end

    #------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------
    def call
      url = "https://www.instagram.com/api/v1/users/web_profile_info/?username=#{@profile.username}"

      headers = { 'x-ig-app-id': '936619743392459' }
      response = HTTParty.get(url, headers:, timeout: 60)
      data = JSON.parse(response.body)

      posts = data['data']['user']['edge_owner_to_timeline_media']['edges']
      videos = data['data']['user']['edge_felix_video_timeline']['edges']

      handle_success(posts + videos)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
