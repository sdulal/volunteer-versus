require 'test_helper'

class EventManagementTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:generic_user)
    @group = groups(:generic_group)
    @event = events(:generic_event)
    @user.join(@group)
    @group.promote_to_admin(@user)
    log_in_as(@user)
  end

end
