class MembershipsController < ApplicationController
  before_action :logged_in_user

  def create
    @group = Group.find(params[:group_id])
    current_user.join(@group)
    redirect_to @group
  end

  def destroy
    @group = Membership.find(params[:id]).group
    current_user.quit(@group)
    redirect_to @group
  end
end
