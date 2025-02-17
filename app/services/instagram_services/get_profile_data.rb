# frozen_string_literal: true

module InstagramServices
  class GetProfileData < ApplicationService
    def initialize(uid)
      @uid = uid
    end

    def call
      url = 'https://www.instagram.com/graphql/query'

      headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
      variables = { id: @uid, render_surface: 'PROFILE' }
      doc_id = '28149645878012614'

      # Encode variables into a query string format
      encoded_variables = CGI.escape(variables.to_json)
      body = "variables=#{encoded_variables}&doc_id=#{doc_id}"

      response = HTTParty.post(url, headers:, body:, timeout: 60)

      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
