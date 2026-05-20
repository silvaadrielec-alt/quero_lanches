require "test_helper"

class FluxoDeCaixaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fluxo_de_caixa_index_url
    assert_response :success
  end
end
