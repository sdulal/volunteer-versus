require 'test_helper'

class MembershipsInterfaceTest < ActionDispatch::IntegrationTest
  # Goals:
  # Test the user's groups page*
  # Test user's ability to join a group (ajax method planned)
  # Maybe: Test a user's admin groups page (groups he/she is admin of)

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
  end

  test "joining group" do
    # Join the group
    log_in_as(@user)
    get group_path(@group)
    assert_template 'groups/show'
    assert_select 'form', class: 'new_membership'
    assert_difference '@user.groups.count', 1 do
      post memberships_path, group_id: @group.id
    end
    assert_redirected_to @group
    follow_redirect!
    assert_select 'form', class: 'edit_membership'
    # See that the group shows up in user profile
    get groups_user_path(@user)
    assert_template 'users/groups'
    assert_select 'a[href=?]', group_path(@group), text: @group.name
  end
end
