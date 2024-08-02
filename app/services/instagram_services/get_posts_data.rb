# frozen_string_literal: true

module InstagramServices
  class GetPostsData < ApplicationService
    def initialize(profile)
      @profile = profile
    end

    def call
      request = CGI.escape("https://www.instagram.com/graphql/query/?doc_id=17991233890457762&variables={\"id\":\"#{@profile.uid}\",\"first\":24}")
      url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{request}"

      response = HTTParty.get(url, format: :plain, timeout: 60)
      raise StandardError, 'Empty response body' if response.body.empty?

      data = JSON.parse(response.body)
      data = data['data']['user']['edge_owner_to_timeline_media']['edges']
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
