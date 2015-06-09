require 'test_helper'

class GroupsControllerTest < ActionController::TestCase

  def setup
    @group = groups(:key)
    @admin = users(:nick)
    @non_admin = users(:chris)
  end

  test "should get new when logged in" do
    log_in_as(@admin)
    get :new
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Group.count' do
      post :create, group: { name: "Spam", description: "Waste of space" }
    end
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @group.id
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as non-admin" do
    log_in_as(@non_admin)
    @non_admin.join(@group)
    get :edit, id: @group.id
    assert_redirected_to group_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @group.id, group: { name: "Bad", description: "Stuff" }
    assert_redirected_to login_url
    assert_not @group.changed?
  end

  test "should redirect update when logged in as non-admin" do
    log_in_as(@non_admin)
    @non_admin.join(@group)
    patch :update, id: @group.id, group: { name: "Bad", description: "Stuff" }
    assert_redirected_to group_url
    assert_not @group.changed?
  end

  test "should patch update when logged in as admin" do
    log_in_as(@admin)
    patch :update, id: @group.id, group: { name: "Key", description: "Key to Success" }
    assert_redirected_to group_url
    @group.reload
    assert_equal "Key to Success", @group.description
  end

  test "should get edit when logged in as admin" do
    log_in_as(@admin)
    get :edit, id: @group.id
    assert_response :success
  end

  test "should redirect show when not logged in" do
    get :show, id: @group.id
    assert_redirected_to login_url
  end

  test "should get show when logged in" do
    log_in_as(@admin)
    get :show, id: @group.id
    assert_response :success
  end

  test "should redirect destroy when not logged in" do
    get :destroy, id: @group.id
    assert_redirected_to login_url
    assert Group.exists?(@group.id)
  end

  test "should redirect destroy when logged in as non-admin" do
    log_in_as(@non_admin)
    @non_admin.join(@group)
    get :destroy, id: @group.id
    assert_redirected_to group_url
    assert Group.exists?(@group.id)
  end

  test "should destroy when logged in as admin" do
    log_in_as(@admin)
    get :destroy, id: @group.id
    assert_redirected_to groups_url
    assert_not Group.exists?(@group.id)
  end
end
