require 'test_helper'

class OvensControllerTest < ActionController::TestCase

  #Index method  test cases
  test "get ovens with valid existing factory data" do
    @request.headers['HTTP_AUTHORIZATION']="NDU3OGM4MzYtM2RlOS00NzcxLWI5MTUtZDIxZmU5ZGE0MzlkfGh0dHA6Ly8yMDMuMjA2LjE4Ny4yMTQ6ODg4OHwyOTEzNTYxNjB8Z3Vlc3R8Z3Vlc3Q="
    get :index, format: 'text/json',params:{factory_id:2}
    assert_response 200
    assert JSON.parse(@response.body).length>0
  end

  test "get ovens with not existing factory data" do
    @request.headers['HTTP_AUTHORIZATION']="NDU3OGM4MzYtM2RlOS00NzcxLWI5MTUtZDIxZmU5ZGE0MzlkfGh0dHA6Ly8yMDMuMjA2LjE4Ny4yMTQ6ODg4OHwyOTEzNTYxNjB8Z3Vlc3R8Z3Vlc3Q="
    get :index, format: 'text/json',params:{factory_id:7}
    assert_response 200
    assert_equal JSON.parse(@response.body).length,0
  end


  test "get ovens with no factory Id" do
    @request.headers['HTTP_AUTHORIZATION']="NDU3OGM4MzYtM2RlOS00NzcxLWI5MTUtZDIxZmU5ZGE0MzlkfGh0dHA6Ly8yMDMuMjA2LjE4Ny4yMTQ6ODg4OHwyOTEzNTYxNjB8Z3Vlc3R8Z3Vlc3Q="
    get :index, format: 'text/json'
    assert_response 422
  end
end
