require 'test_helper'

class BasePointsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get base_points_new_url
    assert_response :success
  end

end
