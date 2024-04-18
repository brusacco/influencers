# frozen_string_literal: true

module InstagramServices
  class GetProfileData < ApplicationService
    def initialize(username)
      @username = username
    end

    def call
      url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=https://www.instagram.com/#{@username}/?__a=1"
      response = HTTParty.get(url)
      data = JSON.parse(response.body)
      result = { data: data }
      handle_success(result)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
