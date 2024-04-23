# frozen_string_literal: true

require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get profiles_url
    assert_response :success
  end
end
