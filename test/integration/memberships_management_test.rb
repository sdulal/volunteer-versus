require 'test_helper'

class MembershipsManagementTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    log_in_as(@user)
  end

  test "sole admin cannot leave group" do
    install_user_as_group_admin(@user, @group)
    get group_path(@group)
    assert_no_difference '@user.groups.count' do
      delete membership_path(@user.membership_for(@group))
    end
    assert_not flash.empty?
    assert_redirected_to @group
    follow_redirect!
    assert_match "other group admins", response.body
  end

  test "admin can leave group when multiple admins exist" do
    5.times do |n|
      key = "user_" + n.to_s
      user = users(key)
      user.join(@group)
    end
    install_user_as_group_admin(@user, @group)
    get group_members_path(@group)
    assert_template 'groups/members'
    membership = @group.memberships.second
    assert_difference '@group.admins.count', 1 do
      put membership_path(membership), membership: { admin: true }
    end
    assert_not flash.empty?
    assert_redirected_to group_members_path(@group)
    get group_path(@group)
    assert_difference '@group.admins.count', -1 do
      delete membership_path(@user.membership_for(@group))
    end
    assert_not flash.empty?
    assert_redirected_to @group
    follow_redirect!
    assert_match "Quit", response.body
  end

end
