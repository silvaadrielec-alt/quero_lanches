require "test_helper"

class NotificacaosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get notificacaos_index_url
    assert_response :success
  end
end
