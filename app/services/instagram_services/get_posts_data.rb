# frozen_string_literal: true

module InstagramServices
  class GetPostsData < ApplicationService
    def initialize(profile)
      @profile = profile
    end

    def call
      query = { id: @profile.uid, first: 24 }
      escaped_query = CGI.escape(query.to_json)

      request_url = "https://www.instagram.com/graphql/query/?doc_id=17991233890457762&variables=#{escaped_query}"
      api_url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{CGI.escape(request_url)}"

      response = HTTParty.get(api_url, format: :plain, timeout: 60)
      raise StandardError, 'Empty response body' if response.body.empty?

      data1 = JSON.parse(response.body)
      data1 = data1['data']['user']['edge_owner_to_timeline_media']['edges']

      if data['data']['user']['edge_owner_to_timeline_media']['page_info']['has_next_page']
        end_cursor = data['data']['user']['edge_owner_to_timeline_media']['page_info']['end_cursor']
        request = CGI.escape("https://www.instagram.com/graphql/query/?doc_id=17991233890457762&variables={\"id\":\"#{@profile.uid}\",\"first\":24,\"after\":\"#{end_cursor}\"}")
        url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{request}"
        response = HTTParty.get(url, format: :plain, timeout: 60)
        raise StandardError, 'Empty response body' if response.body.empty?

        data2 = JSON.parse(response.body)
        data2 = data2['data']['user']['edge_owner_to_timeline_media']['edges']
      end

      handle_success(data1 + data2)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
