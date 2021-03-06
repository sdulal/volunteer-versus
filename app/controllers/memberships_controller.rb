class MembershipsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: :update
  before_action :prevent_zero_group_admins, only: :destroy

  # Joining a group.
  def create
    @group = Group.find(params[:group_id])
    current_user.join(@group)
    flash[:success] = "Joined #{@group.name} successfully!"
    redirect_to @group
  end

  # Updating a membership (for things like admin status).
  def update
    @membership = Membership.find(params[:id])
    if @membership.update_attributes(membership_params)
      flash[:success] = "Updated membership."
      redirect_to group_members_url(@group)
    end
  end

  # Deleting a membership (through admin or by quitting).
  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy
    if @membership.user == current_user
      flash[:success] = "Quit #{@group.name} successfully."
      redirect_to @membership.group
    else
      flash[:success] = "Removed member successfully."
      redirect_to group_members_url(@membership.group)
    end
  end

  private

    # Limit what parameters can be changed through forms.
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
