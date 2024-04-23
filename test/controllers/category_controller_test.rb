# frozen_string_literal: true

require 'test_helper'

class CategoryControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get category_show_path(1)
    assert_response :success
  end
end
