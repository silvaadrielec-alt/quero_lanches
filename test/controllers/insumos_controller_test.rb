require "test_helper"

class InsumosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get insumos_index_url
    assert_response :success
  end

  test "should get show" do
    get insumos_show_url
    assert_response :success
  end

  test "should get new" do
    get insumos_new_url
    assert_response :success
  end

  test "should get edit" do
    get insumos_edit_url
    assert_response :success
  end
end
