require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get update" do
    get :update, id: 1
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: 2
    assert_response :success
  end

  test "should get destroy" do
    get :destroy, id: 3
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, id: 1
    assert_response :success
  end

end
