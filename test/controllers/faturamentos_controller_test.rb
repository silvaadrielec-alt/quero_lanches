require "test_helper"

class FaturamentosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get faturamentos_index_url
    assert_response :success
  end
end
