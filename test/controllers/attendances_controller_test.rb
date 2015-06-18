require 'test_helper'

class AttendancesControllerTest < ActionController::TestCase

  def setup
    @group_admin = users(:nick)
    @member = users(:stephen)
    @non_member = users(:chris)
    @group = groups(:key)
    @event = events(:keynect)
    @attendance = attendances(:nick_key)
  end

  test "should redirect everything if not logged in" do
    get :index, event_id: @event
    assert_redirected_to login_url
    post :create, event_id: @event
    assert_redirected_to login_url
    get :edit, id: @attendance.id
    assert_redirected_to login_url
    patch :update, id: @attendance.id
    assert_redirected_to login_url
    delete :destroy, id: @attendance.id
    assert_redirected_to login_url
  end

  test "should redirect create if not member of group" do
    log_in_as(@non_member)
    post :create, event_id: @event
    assert_redirected_to @group
  end

  test "should redirect destroy if not member of group" do
    log_in_as(@non_member)
    delete :destroy, id: @attendance.id
    assert_redirected_to @group
  end

  test "should redirect edit if not member" do
    log_in_as(@non_member)
    get :edit, id: @attendance.id
    assert_redirected_to @group
  end

  test "should redirect edit if not admin" do
    log_in_as(@member)
    get :edit, id: @attendance.id
    assert_redirected_to @event
  end

  test "should redirect update if not member" do
    log_in_as(@non_member)
    patch :update, id: @attendance.id
    assert_redirected_to @group
  end

  test "should redirect update if not admin" do
    log_in_as(@member)
    patch :update, id: @attendance.id
    assert_redirected_to @event
  end
end
