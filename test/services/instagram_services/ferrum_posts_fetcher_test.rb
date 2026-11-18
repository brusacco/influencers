# frozen_string_literal: true

require 'test_helper'

class FerrumPostsFetcherTest < ActiveSupport::TestCase
  setup do
    @fetcher = InstagramServices::FerrumPostsFetcher.new(profiles(:one))
  end

  test 'maps the public GraphQL media fields used by the post upserter' do
    attributes = @fetcher.send(
      :post_attributes,
      {
        'code' => 'graphql-post',
        'media_type' => 2,
        'product_type' => 'clips',
        'caption' => { 'text' => 'GraphQL caption' },
        'like_count' => 123,
        'like_and_view_counts_disabled' => false
      }
    )

    assert_equal 'graphql-post', attributes[:shortcode]
    assert_equal 'https://www.instagram.com/p/graphql-post/', attributes[:url]
    assert_equal 'GraphVideo', attributes[:media]
    assert_equal 'clips', attributes[:product_type]
    assert_equal 'GraphQL caption', attributes[:caption]
    assert_equal 123, attributes[:likes_count]
  end

  test 'ignores GraphQL nodes without a shortcode' do
    assert_nil @fetcher.send(:post_attributes, { 'media_type' => 1 })
  end
end
