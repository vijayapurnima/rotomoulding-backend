require 'test_helper'

class FactoriesControllerTest < ActionController::TestCase

  #Index method  test cases
  test "get factories with valid data" do
    @request.headers['HTTP_AUTHORIZATION']="NDU3OGM4MzYtM2RlOS00NzcxLWI5MTUtZDIxZmU5ZGE0MzlkfGh0dHA6Ly8yMDMuMjA2LjE4Ny4yMTQ6ODg4OHwyOTEzNTYxNjB8Z3Vlc3R8Z3Vlc3Q="
    get :index, format: 'text/json'
    assert_response 200
    assert_includes @response.body,"QLD"
    assert_includes @response.body,"VIC"
  end

  end
