# frozen_string_literal: true

module InstagramServices
  class GetPostsData < ApplicationService
    def initialize(profile)
      @profile = profile
    end

    def call
      url = @profile.query
      response = HTTParty.get(url, format: :plain, timeout: 60)
      raise StandardError, 'Empty response body' if response.body.empty?

      #data = JSON.parse(response.body, symbolize_names: true)
      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
