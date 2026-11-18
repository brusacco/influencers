# frozen_string_literal: true

require 'test_helper'

class FerrumPostUpserterTest < ActiveSupport::TestCase
  test 'persists GraphQL attributes and retains existing values absent from the response' do
    profile = profiles(:one)
    post = profile.instagram_posts.create!(
      shortcode: 'existing-post',
      comments_count: 19,
      posted_at: Time.zone.parse('2026-11-01 12:00:00'),
      data: { 'source' => 'legacy' }
    )

    result = InstagramServices::FerrumPostUpserter.call(
      profile,
      shortcode: post.shortcode,
      url: 'https://www.instagram.com/p/existing-post/',
      media: 'GraphImage',
      caption: 'Updated from GraphQL',
      likes_count: 42,
      metadata: {
        'code' => post.shortcode,
        'pk' => '123',
        'carousel_media' => Array.new(20) { { 'image_versions2' => { 'candidates' => Array.new(10, 'large-image-url') } } }
      }
    )

    assert_predicate result, :success?
    post.reload
    assert_equal 42, post.likes_count
    assert_equal 19, post.comments_count
    assert_equal Time.zone.parse('2026-11-01 12:00:00'), post.posted_at
    assert_equal 'legacy', post.data['source']
    assert_equal post.shortcode, post.data.dig('ferrum', 'code')
    assert_equal '123', post.data.dig('ferrum', 'pk')
    assert_nil post.data.dig('ferrum', 'carousel_media')
  end
end
