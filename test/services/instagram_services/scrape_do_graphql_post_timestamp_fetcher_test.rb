# frozen_string_literal: true

require 'test_helper'

class ScrapeDoGraphqlPostTimestampFetcherTest < ActiveSupport::TestCase
  test 'uses the canonical feed URL instead of a stored legacy URL' do
    post = OpenStruct.new(shortcode: 'abc123', product_type: 'feed', url: 'https://www.instagram.com/example/p/abc123/')

    assert_equal 'https://www.instagram.com/p/abc123/',
                 InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.new(post).send(:post_url)
  end

  test 'uses the canonical reel URL for clips' do
    post = OpenStruct.new(shortcode: 'abc123', product_type: 'clips', url: 'https://www.instagram.com/example/reel/abc123/')

    assert_equal 'https://www.instagram.com/reel/abc123/',
                 InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.new(post).send(:post_url)
  end

  test 'extracts the publication timestamp for the requested shortcode' do
    post = OpenStruct.new(shortcode: 'abc123', product_type: nil, url: nil)
    fetcher = InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.new(post)
    payload = {
      'data' => {
        'media' => {
          'code' => 'abc123',
          'taken_at' => 1_735_689_600
        }
      }
    }

    assert_equal Time.zone.at(1_735_689_600), fetcher.send(:extract_details, payload)[:posted_at]
    assert_equal 0, fetcher.send(:extract_details, payload)[:comments_count]
    assert_equal 'abc123', fetcher.send(:extract_details, payload).dig(:metadata, 'code')
  end

  test 'rejects a detail payload without a publication timestamp' do
    post = OpenStruct.new(shortcode: 'abc123', product_type: nil, url: nil)
    fetcher = InstagramServices::ScrapeDoGraphqlPostTimestampFetcher.new(post)

    error = assert_raises(RuntimeError) { fetcher.send(:extract_details, 'data' => {}) }
    assert_equal 'Instagram post detail GraphQL response did not include a publication timestamp', error.message
  end
end
