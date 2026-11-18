# frozen_string_literal: true

require 'test_helper'

class GetProfileDataTest < ActiveSupport::TestCase
  test 'adapts the public GraphQL profile into the legacy payload contract' do
    graphql_result = OpenStruct.new(
      success?: true,
      data: {
        'pk' => '123',
        'username' => 'example',
        'full_name' => 'Example Account',
        'biography' => 'Public profile',
        'follower_count' => 456,
        'following_count' => 7,
        'profile_pic_url' => 'https://example.test/avatar.jpg',
        'is_private' => false,
        'is_verified' => true
      }
    )

    InstagramServices::ScrapeDoGraphqlProfileFetcher.stub(:call, graphql_result) do
      result = InstagramServices::GetProfileData.call('example')

      assert_predicate result, :success?
      user = result.data.dig('data', 'user')
      assert_equal '123', user['id']
      assert_equal 456, user.dig('edge_followed_by', 'count')
      assert_equal 7, user.dig('edge_follow', 'count')
      assert_equal 'https://example.test/avatar.jpg', user['profile_pic_url']
      assert user['is_verified']
      assert_equal false, user['is_embeds_disabled']
    end
  end

  test 'returns the GraphQL fetch error without adapting a payload' do
    graphql_result = OpenStruct.new(success?: false, error: 'profile query unavailable')

    InstagramServices::ScrapeDoGraphqlProfileFetcher.stub(:call, graphql_result) do
      result = InstagramServices::GetProfileData.call('example')

      assert_not_predicate result, :success?
      assert_equal 'profile query unavailable', result.error
    end
  end
end
