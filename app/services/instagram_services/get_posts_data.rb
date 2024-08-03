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
      data = api_call['data']['user']['edge_owner_to_timeline_media']['edges']
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end

    #------------------------------------------------------------------------------
    #
    #------------------------------------------------------------------------------
    def api_call(cursor: nil)
      query = { id: @profile.uid, first: 24, cursor: }
      escaped_query = CGI.escape(query.to_json)

      request_url = "https://www.instagram.com/graphql/query/?doc_id=17991233890457762&variables=#{escaped_query}"
      api_url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{CGI.escape(request_url)}"

      response = HTTParty.get(api_url, format: :plain, timeout: 60)
      JSON.parse(response.body)
    end
  end
end
