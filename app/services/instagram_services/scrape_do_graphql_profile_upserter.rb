# frozen_string_literal: true

module InstagramServices
  # Applies only profile attributes present in the public GraphQL response.
  class ScrapeDoGraphqlProfileUpserter < ApplicationService
    ATTRIBUTE_MAPPING = {
      'follower_count' => :followers,
      'following_count' => :following,
      'profile_pic_url' => :profile_pic_url,
      'is_private' => :is_private,
      'is_verified' => :is_verified,
      'full_name' => :full_name,
      'biography' => :biography,
      'pk' => :uid
    }.freeze

    def initialize(profile, data)
      @profile = profile
      @data = data
    end

    def call
      validate!
      @profile.update!(attributes)
      handle_success(@profile)
    rescue StandardError => e
      Rails.logger.error("[ScrapeDoGraphqlProfileUpserter] @#{@profile&.username}: #{e.class} - #{e.message}")
      handle_error(e.message)
    end

    private

    def validate!
      raise ArgumentError, 'Profile cannot be nil' if @profile.nil?
      raise ArgumentError, 'Profile GraphQL data must be a Hash' unless @data.is_a?(Hash)
    end

    def attributes
      ATTRIBUTE_MAPPING.each_with_object({}) do |(source, destination), result|
        result[destination] = @data[source] if @data.key?(source)
      end
    end
  end
end
