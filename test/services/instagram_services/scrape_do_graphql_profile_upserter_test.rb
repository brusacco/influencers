# frozen_string_literal: true

require 'test_helper'

class ScrapeDoGraphqlProfileUpserterTest < ActiveSupport::TestCase
  test 'updates public GraphQL fields without replacing unavailable attributes' do
    profile = profiles(:one)
    profile.update!(category_name: 'Existing category')

    result = InstagramServices::ScrapeDoGraphqlProfileUpserter.call(
      profile,
      'follower_count' => 123,
      'following_count' => 45,
      'full_name' => 'GraphQL profile',
      'biography' => 'Updated biography',
      'is_verified' => true,
      'is_private' => false,
      'profile_pic_url' => 'https://example.test/avatar.jpg',
      'pk' => '999'
    )

    assert_predicate result, :success?
    profile.reload
    assert_equal 123, profile.followers
    assert_equal 45, profile.following
    assert_equal 'GraphQL profile', profile.full_name
    assert_equal 'Existing category', profile.category_name
    assert_equal 999, profile.uid
  end
end
