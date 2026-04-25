require "test_helper"

class RelatoriosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get relatorios_index_url
    assert_response :success
  end
end
