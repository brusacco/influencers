# frozen_string_literal: true

require 'cgi'

module InstagramServices
  class GetProfileCursor < ApplicationService
    def initialize(user_id, cursor)
      @user_id = user_id
      @cursor = cursor
    end

    def call
      query_hash = 'eddbde960fed6bde675388aac39a3657'
      par = {}
      par['id'] = @user_id
      par['first'] = '50'
      par['after'] = @cursor

      url = CGI.escape("https://www.instagram.com/graphql/query/?query_hash=#{query_hash}&variables=#{par.to_json}")
      url = "http://api.scrape.do?token=ed138ed418924138923ced2b81e04d53&url=#{url}"

      response = HTTParty.get(url)
      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
