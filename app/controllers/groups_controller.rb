class GroupsController < ApplicationController
  before_action :logged_in_user
  before_action :member_user, except: [:index, :new, :create, :show]
  before_action :admin_user, only: [:edit, :update, :destroy]

  # Set up for the new group form.
  def new
    @group = Group.new
  end

  # Create a new group.
  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:success] = "Group created!"
      current_user.join(@group)
      @group.promote_to_admin(current_user)
      redirect_to group_url(@group)
    else
      render 'new'
    end
  end

  # Update details on a group.
  def update
    @group = Group.find(by_id)
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated"
      redirect_to @group
    else
      render 'edit'
    end
  end

  # Editing a group.
  def edit
    @group = Group.find(by_id)
  end

  # Deleting a group.
  def destroy
    Group.find(by_id).destroy
    flash[:success] = "Group deleted"
    redirect_to groups_url
  end

  # Listing all the groups, in order of hours.
  def index
    @groups = Group.order(hours: :desc).paginate(page: params[:page])
    @incrementer = 30 * (params[:page].to_i - 1) + 1
    if @incrementer < 0
      @incrementer = 1
    end
  end

  # Viewing a particular group. Display depends on membership.
  def show
    @group = Group.find(by_id)
    if @group.has_member?(current_user)
      @your_hours = current_user.membership_for(@group).hours
    end
  end

  # View all the members in a certain group.
  def members
    @group = Group.find(params[:group_id])
    @members = @group.users
  end

  private

    # Limit what parameters can be changed through forms.
    def group_params
      params.require(:group).permit(:name, :description)
    end

    # Certain pages should be accessed only by members.
    def member_user
      if params[:group_id]
        @group = Group.find(params[:group_id])
      else
        @group = Group.find(by_id)
      end
      unless @group.has_member?(current_user)
        flash[:danger] = "The page you requested is only available to members."
        redirect_to @group
      end
    end

    # Certain pages should be accessed only by group admins.
    def admin_user
      @group = Group.find(by_id)
      redirect_to @group unless @group.has_admin?(current_user)
    end
end
