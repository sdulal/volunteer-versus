require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def setup
    @group = groups(:key)
  end

  test "should be valid" do
    assert @group.valid?
  end

  test "name should be present" do
    @group.name = ""
    assert_not @group.valid?
  end

  test "may not have description" do
    @group.description = ""
    assert @group.valid?
  end
end
