# frozen_string_literal: true

module InstagramServices
  class GetProfileData < ApplicationService
    def initialize(username)
      @username = username
    end

    def call
      proxy = 'http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url='
      url = "#{proxy}https://www.instagram.com/api/v1/users/web_profile_info/?username=#{@username}"

      ig_headers = { 'x-ig-app-id' => '936619743392459', 'x-requested-with' => 'XMLHttpRequest' }

      response = HTTParty.get(url, headers: ig_headers)
      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
