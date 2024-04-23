# frozen_string_literal: true

module InstagramServices
  class GetRelatedProfiles < ApplicationService
    def initialize(data)
      @data = data
    end

    def call
      usernames = []
      @data['data']['user']['edge_related_profiles']['edges'].map do |edge|
        usernames << edge['node']['username']
      end
      handle_success(usernames)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
