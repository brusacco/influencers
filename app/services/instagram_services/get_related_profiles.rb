# frozen_string_literal: true

module InstagramServices
  # Service to extract related profile usernames from Instagram data
  # Parses the edge_related_profiles structure and returns an array of usernames
  # @example
  #   result = InstagramServices::GetRelatedProfiles.call(raw_data)
  #   if result.success?
  #     usernames = result.data # Array of username strings
  #   end
  class GetRelatedProfiles < ApplicationService
    def initialize(data)
      @data = data
    end

    def call
      validate_data!
      
      edges = extract_related_profiles_edges
      usernames = extract_usernames(edges)
      
      Rails.logger.info("[GetRelatedProfiles] Found #{usernames.count} related profiles")
      handle_success(usernames)
    rescue ArgumentError, StandardError => e
      Rails.logger.error("[GetRelatedProfiles] Error: #{e.message}")
      handle_error(e.message)
    end

    private

    # Validate that data exists and has expected structure
    # @raise [ArgumentError] if data is invalid
    def validate_data!
      raise ArgumentError, 'Data cannot be nil' if @data.nil?
      raise ArgumentError, 'Data must be a Hash' unless @data.is_a?(Hash)
      raise ArgumentError, 'Missing data.user structure' unless @data.dig('data', 'user')
    end

    # Extract related profiles edges from data
    # @return [Array] Array of edge hashes
    def extract_related_profiles_edges
      edges = @data.dig('data', 'user', 'edge_related_profiles', 'edges')
      
      unless edges.is_a?(Array)
        Rails.logger.warn('[GetRelatedProfiles] No related profiles found')
        return []
      end
      
      edges
    end

    # Extract usernames from edges
    # @param edges [Array] Array of edge hashes
    # @return [Array<String>] Array of usernames
    def extract_usernames(edges)
      edges.filter_map do |edge|
        username = edge.dig('node', 'username')
        
        if username.blank?
          Rails.logger.warn('[GetRelatedProfiles] Edge missing username, skipping')
          next
        end
        
        username
      end
    end
  end
end
