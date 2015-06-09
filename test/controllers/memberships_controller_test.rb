require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
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
end
