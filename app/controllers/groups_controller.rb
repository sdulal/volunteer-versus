class GroupsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:edit, :update, :destroy]

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "Group created!"
      current_user.join(@group)
      @group.promote_to_admin(current_user)
      redirect_to group_url(@group)
    else
      redirect_to new_group_url
    end
  end

  def update
    @group = Group.find(by_id)
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated"
      redirect_to @group
    else
      render 'edit'
    end
  end

  def edit
    @group = Group.find(by_id)
  end

  def destroy
    Group.find(by_id).destroy
    flash[:success] = "Group deleted"
    redirect_to groups_url
  end

  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(by_id)
  end

  private

    def group_params
      params.require(:group).permit(:name, :description)
    end

    def admin_user
      @group = Group.find(by_id)
      redirect_to @group unless @group.has_admin?(current_user)
    end
end
