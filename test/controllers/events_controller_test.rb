require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  def setup
    # Note: Nick is a site AND group admin.
    @admin = users(:nick)
    @non_admin = users(:chris)
    @group = groups(:key)
    @event = events(:keynect)
  end

  test "should redirect create if not admin" do
    # No log in
    event = @event.dup
    event.id = 9
    event.name = "KeyNection Alternate"
    assert_no_difference 'Event.count' do
      post :create, id: @group.id
    end
    assert_redirected_to login_url
    # Log in as non-member
    log_in_as(@non_admin)
    assert_no_difference 'Event.count' do
      post :create, id: @group.id
    end
    assert_redirected_to @group
    # Log in as non-admin member
    @non_admin.join(@group)
    assert_no_difference 'Event.count' do
      post :create, id: @group.id
    end
    assert_redirected_to @group
  end

  test "should redirect destroy if not admin" do
    # No log in
    assert_no_difference 'Event.count' do
      delete :destroy, id: @group.id, event_id: @event.id
    end
    assert_redirected_to login_url
    # Log in as non-member
    log_in_as(@non_admin)
    assert_no_difference 'Event.count' do
      delete :destroy, id: @group.id, event_id: @event.id
    end
    assert_redirected_to @group
    # Log in as non-admin member
    @non_admin.join(@group)
    assert_no_difference 'Event.count' do
      delete :destroy, id: @group.id, event_id: @event.id
    end
    assert_redirected_to @group
  end

  test "should redirect everything if not logged in" do
    get :index, id: @group.id
    assert_redirected_to login_url
    get :new, id: @group.id
    assert_redirected_to login_url
    post :create, id: @group.id
    assert_redirected_to login_url
    get :edit, id: @group.id
    assert_redirected_to login_url
    patch :update, id: @group.id
    assert_redirected_to login_url
    get :show, id: @group.id
    assert_redirected_to login_url
    delete :destroy, id: @group.id
    assert_redirected_to login_url
  end

end
