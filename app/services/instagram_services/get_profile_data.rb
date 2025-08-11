# frozen_string_literal: true

module InstagramServices
  class GetProfileData < ApplicationService
    def initialize(username)
      @username = username
    end

    def call
      url = "https://www.instagram.com/api/v1/users/web_profile_info/?username=#{@username}"
      api_url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{CGI.escape(url)}"

      headers = { 'Content-Type': 'application/x-www-form-urlencoded', 'x-ig-app-id': '936619743392459' }

      response = HTTParty.get(api_url, headers:, timeout: 60)

      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
