# frozen_string_literal: true

require 'test_helper'

class InstagramPostsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get posts_url
    assert_response :success
  end
end
