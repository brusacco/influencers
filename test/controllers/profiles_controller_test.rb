# frozen_string_literal: true

require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get profile_index_url
    assert_response :success
  end
end
