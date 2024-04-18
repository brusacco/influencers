# frozen_string_literal: true

module InstagramServices
  class GetPostsData < ApplicationService
    def initialize(profile)
      @profile = profile
    end

    def call
      url = "https://www.instagram.com/graphql/query/?doc_id=17991233890457762&variables=%7B%22id%22:%22#{@profile.uid}%22,%22first%22:100%7D"
      response = HTTParty.get(url, format: :plain, timeout: 60)
      raise StandardError, 'Empty response body' if response.body.empty?

      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
