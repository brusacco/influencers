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
      api_url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{CGI.escape(url)}"

      headers = { 'x-ig-app-id': '936619743392459' }
      response = HTTParty.get(api_url, headers:, timeout: 60)
      data = JSON.parse(response.body)

      puts data

      posts = data['data']['user']['edge_owner_to_timeline_media']['edges']
      videos = data['data']['user']['edge_felix_video_timeline']['edges']

      handle_success(posts + videos)
    # rescue StandardError => e
    #   handle_error(e.message)
    end
  end
end
