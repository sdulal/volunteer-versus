require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
  end

  test "create should require logged-in user" do
    assert_no_difference 'Membership.count' do
      post :create
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Membership.count' do
      delete :destroy, id: memberships(:one)
    end
    assert_redirected_to login_url
  end

  test "update should require admin" do
    @user.join(@group)
    log_in_as(@user)
    put :update, id: @user.membership_for(@group), membership: { admin: true }
    assert_redirected_to group_members_url(@group)
    assert_not @group.has_admin?(@user)
  end
end
