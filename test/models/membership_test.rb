require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  def setup
    @membership = memberships(:one)
  end

  test "should be valid" do
    assert @membership.valid?
  end

  test "user should be present" do
    @membership.user = nil
    assert_not @membership.valid?
  end

  test "group should be present" do
    @membership.group = nil
    assert_not @membership.valid?
  end

  test "membership should be unique" do
    assert_raise do
      @membership.user.join(@membership.group)
    end
  end
end
