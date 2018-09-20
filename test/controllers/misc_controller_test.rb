require 'test_helper'

class MiscControllerTest < ActionDispatch::IntegrationTest
  test "should get maintenance" do
    get misc_maintenance_url
    assert_response :success
  end

end
