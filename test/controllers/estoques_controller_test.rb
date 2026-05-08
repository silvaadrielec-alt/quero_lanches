require "test_helper"

class EstoquesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get estoques_index_url
    assert_response :success
  end

  test "should get edit" do
    get estoques_edit_url
    assert_response :success
  end

  test "should get update" do
    get estoques_update_url
    assert_response :success
  end
end
