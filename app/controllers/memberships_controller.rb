class MembershipsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: :update
  before_action :prevent_zero_group_admins, only: :destroy

  def create
    @group = Group.find(params[:group_id])
    current_user.join(@group)
    respond_to do |format|
      format.html {
        flash[:success] = "Joined #{@group.name} successfully!"
        redirect_to @group
      }
      format.js
    end
  end

  def update
    @membership = Membership.find(params[:id])
    if @membership.update_attributes(membership_params)
      flash[:success] = "Updated membership."
      redirect_to group_members_url(@group)
    end
  end

  def destroy
    @user = Membership.find(params[:id]).user
    @group = Membership.find(params[:id]).group
    @user.quit(@group)
    respond_to do |format|
      format.html {
        if @user == current_user
          flash[:success] = "Quit #{@group.name} successfully."
          redirect_to @membership.group
        else
          flash[:success] = "Removed member successfully."
          redirect_to group_members_url(@group)
        end
      }
      format.js
    end
  end

  private

    def membership_params
      params.require(:membership).permit(:admin)
    end

    # Checks that a group admin is trying to update membership.
    def admin_user
      @group = Membership.find(params[:id]).group
      redirect_to group_members_url(@group) unless @group.has_admin?(current_user)
    end

    # Ensures that the only admin of a group cannot quit and leave no group admins.
    def prevent_zero_group_admins
      @membership = Membership.find(params[:id])
      @group = @membership.group
      if @group.has_one_admin? && (@membership.user == current_user)
        flash[:danger] = "You cannot quit unless there are other group admins."
        redirect_to @group
      end
    end
end
