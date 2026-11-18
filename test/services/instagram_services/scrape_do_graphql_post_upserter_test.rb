# frozen_string_literal: true

require 'test_helper'

class ScrapeDoGraphqlPostUpserterTest < ActiveSupport::TestCase
  test 'maps a grid node without replacing fields absent from the response' do
    profile = profiles(:one)
    timestamp_result = OpenStruct.new(success?: true, data: Time.zone.at(1_735_689_600))

    InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.stub(:call, timestamp_result) do
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
      assert_equal Time.zone.at(1_735_689_600), post.posted_at
    end
  end

  test 'does not fetch a timestamp when the post already has one' do
    profile = profiles(:one)
    post = profile.instagram_posts.create!(shortcode: 'dated-grid-post', posted_at: Time.zone.at(1_700_000_000))

    timestamp_fetcher = ->(_) { flunk 'timestamp fetcher should not run for a dated post' }
    InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.stub(:call, timestamp_fetcher) do
      result = InstagramServices::ScrapeDoGraphqlPostUpserter.call(profile, 'code' => post.shortcode, 'media_type' => 1)

      assert_predicate result, :success?
      assert_equal Time.zone.at(1_700_000_000), post.reload.posted_at
    end
  end
end
