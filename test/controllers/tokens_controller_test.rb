require "test_helper"

class TokensControllerTest < ActionDispatch::IntegrationTest
  test "should get refresh" do
    get tokens_refresh_url
    assert_response :success
  end
end
