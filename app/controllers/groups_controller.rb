class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      # flash that group has been created.
      # Set up membership and admin for creator.
      flash[:success] = "Group created!"
      redirect_to group_url(@group)
    else
      redirect_to new_group_url
    end
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end


  private

    def group_params
      params.require(:group).permit(:name, :description)
    end
end
