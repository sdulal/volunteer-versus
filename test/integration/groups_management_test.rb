require 'test_helper'

class GroupsManagementTest < ActionDispatch::IntegrationTest
  # Goals:
  # Test group creation page.
  # Test group page
  # Test group editing page.
  # Test group members page.
  # Test group events page.

  # def setup
  #   @admin_of_site_and_key = users(:nick)
  #   @admin_of_key = users(:stephen)
  #   @non_admin = users(:chris)
  #   @group = groups(:key)
  # end

  # test "index including pagination" do
  #   log_in_as(@admin_of_site_and_key)
  #   get groups_path
  #   assert_template 'groups/index'
  #   assert_select 'div.pagination'
  #   first_page_of_groups = Group.order(hours: :desc).paginate(page: 1)
  #   first_page_of_groups.each do |group|
  #     assert_select 'a[href=?]', group_path(group), text: group.name
  #     assert_match group.hours.count, response.body
  #     assert_match group.users.count, response.body
  #   end
  # end

  # test "show page as group admin" do
  #   log_in_as(@admin_of_key)
  #   get group_path(@group)
  #   assert_template 'groups/show'
  #   assert_match @group.description, response.body
  #   assert_select 'title', @group.name
  # end
end
