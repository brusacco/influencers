# frozen_string_literal: true

require 'test_helper'

class GetPostsDataTest < ActiveSupport::TestCase
  test 'returns public GraphQL media nodes' do
    profile = OpenStruct.new(username: 'example')
    graphql_result = OpenStruct.new(success?: true, data: [{ 'code' => 'abc123' }])

    InstagramServices::ScrapeDoGraphqlPostsFetcher.stub(:call, graphql_result) do
      result = InstagramServices::GetPostsData.call(profile)

      assert_predicate result, :success?
      assert_equal [{ 'code' => 'abc123' }], result.data
    end
  end

  test 'returns the GraphQL fetch error' do
    profile = OpenStruct.new(username: 'example')
    graphql_result = OpenStruct.new(success?: false, error: 'post grid unavailable')

    InstagramServices::ScrapeDoGraphqlPostsFetcher.stub(:call, graphql_result) do
      result = InstagramServices::GetPostsData.call(profile)

      assert_not_predicate result, :success?
      assert_equal 'post grid unavailable', result.error
    end
  end
end
