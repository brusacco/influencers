# frozen_string_literal: true

require 'test_helper'

class ScrapeDoGraphqlPostUpserterTest < ActiveSupport::TestCase
  test 'maps a grid node without replacing fields absent from the response' do
    profile = profiles(:one)
    result = InstagramServices::ScrapeDoGraphqlPostUpserter.call(
      profile,
      'code' => 'graphql-grid-post',
      'media_type' => 8,
      'product_type' => 'carousel_container',
      'caption' => { 'text' => 'Grid caption' },
      'pk' => '123'
    )

    assert_predicate result, :success?
    post = result.data
    assert_equal 'GraphSidecar', post.media
    assert_equal 'carousel_container', post.product_type
    assert_equal 'Grid caption', post.caption
    assert_equal '123', post.data.dig('ferrum', 'pk')
  end
end
