require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

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

end
