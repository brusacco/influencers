# frozen_string_literal: true

require 'test_helper'

class ScrapeDoGraphqlPostsFetcherTest < ActiveSupport::TestCase
  setup do
    @fetcher = InstagramServices::ScrapeDoGraphqlPostsFetcher.new('ueno_py', post_limit: 3)
  end

  test 'finds and adapts the profile grid query embedded in HTML' do
    html = <<~HTML
      <script>"queryID":"123","variables":{"first":12,"user_id":"42"},"queryName":"PolarisProfilePostsLoggedOutTabGridUIContentQuery"</script>
    HTML

    query = @fetcher.send(:profile_posts_query, html)

    assert_equal '123', query[:query_id]
    assert_equal 3, query[:variables]['first']
    assert_equal '42', query[:variables]['user_id']
  end

  test 'extracts unique media nodes from a GraphQL response' do
    payload = {
      'data' => {
        'xig_user_by_igid_v2' => {
          'polaris_timeline_connection' => {
          'edges' => [
            { 'node' => { 'code' => 'first' } },
            { 'node' => { 'code' => 'second' } },
            { 'node' => { 'code' => 'first' } }
          ]
          }
        }
      }
    }

    assert_equal %w[first second], @fetcher.send(:extract_posts, payload).map { |node| node['code'] }
  end

  test 'derives a shortcode when GraphQL returns only the media primary key' do
    assert_equal 'B', @fetcher.send(:shortcode_from_pk, 1)
    assert_equal 'BA', @fetcher.send(:shortcode_from_pk, 64)
  end
end
