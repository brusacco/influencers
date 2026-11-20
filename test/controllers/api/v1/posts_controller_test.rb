# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        ENV['API_TOKEN'] = 'test-api-token'

        @brand = profiles(:one)
        @person = profiles(:two)

        @brand.update_columns(
          enabled: true,
          country_string: 'Paraguay',
          profile_type: Profile.profile_types.fetch('marca')
        )
        @person.update_columns(
          enabled: true,
          country_string: 'Paraguay',
          profile_type: Profile.profile_types.fetch('mujer')
        )

        InstagramPost.where(profile: [@brand, @person]).delete_all

        @recent_brand_post = InstagramPost.create!(
          profile: @brand,
          shortcode: 'recent-brand',
          posted_at: 2.hours.ago,
          caption: 'Nueva campaña de verano',
          data: { 'ferrum' => { 'display_uri' => 'https://cdn.example.com/post.jpg' } }
        )
        InstagramPost.create!(
          profile: @brand,
          shortcode: 'old-brand',
          caption: 'Campaña antigua',
          posted_at: 25.hours.ago
        )
        InstagramPost.create!(profile: @person, shortcode: 'recent-person', posted_at: 3.hours.ago)
      end

      teardown do
        ENV.delete('API_TOKEN')
      end

      test 'requires authentication' do
        get '/api/v1/posts'

        assert_response :unauthorized
      end

      test 'lists recent posts filtered by profile type' do
        get '/api/v1/posts', params: { profile_type: 'marca', token: 'test-api-token' }

        assert_response :success
        body = response.parsed_body

        assert_equal 'marca', body['profile_type']
        assert_equal 1, body['total_posts']
        assert_equal ['recent-brand'], body['posts'].pluck('shortcode')
        assert_equal @brand.id, body['posts'].first['profile']['id']
        assert_equal @brand.username, body['posts'].first['profile']['username']
        assert_equal 'https://cdn.example.com/post.jpg', body['posts'].first['post_image_url']
      end

      test 'lists all recent posts when profile type is omitted' do
        get '/api/v1/posts', params: { token: 'test-api-token' }

        assert_response :success
        body = response.parsed_body

        assert_nil body['profile_type']
        assert_equal 2, body['total_posts']
        assert_equal %w[recent-brand recent-person], body['posts'].pluck('shortcode')
      end

      test 'searches post captions across all profiles within the last 24 hours' do
        get '/api/v1/posts/search', params: { q: 'campaña', token: 'test-api-token', limit: 24 }

        assert_response :success
        body = response.parsed_body

        assert_equal 'campaña', body['query']
        assert_equal 24, body['limit']
        assert_equal 1, body['total_posts']
        assert_equal %w[recent-brand], body['posts'].pluck('shortcode')
      end

      test 'search accepts an optional profile type' do
        get '/api/v1/posts/search', params: { q: 'campaña', profile_type: 'mujer', token: 'test-api-token' }

        assert_response :success
        assert_equal 0, response.parsed_body['total_posts']
      end

      test 'requires a search query' do
        get '/api/v1/posts/search', params: { token: 'test-api-token' }

        assert_response :bad_request
        assert_equal 'Query parameter q is required', response.parsed_body['error']
      end

      test 'rejects an unknown profile type in search' do
        get '/api/v1/posts/search', params: { q: 'campaña', profile_type: 'unknown', token: 'test-api-token' }

        assert_response :unprocessable_entity
        assert_includes response.parsed_body['valid_profile_types'], 'marca'
      end

      test 'rejects an unknown profile type' do
        get '/api/v1/posts', params: { profile_type: 'unknown', token: 'test-api-token' }

        assert_response :unprocessable_entity
        assert_includes response.parsed_body['valid_profile_types'], 'marca'
      end
    end
  end
end
