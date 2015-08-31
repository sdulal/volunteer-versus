class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # View all the users.
  def index
    @users = User.order(hours: :desc).paginate(page: params[:page])
    @incrementer = 30 * (params[:page].to_i - 1) + 1
    if @incrementer < 0
      @incrementer = 1
    end
  end

  # See an individual user.
  def show
    @user = User.find(by_id)
    @recent_events = @user.last_n_events(5)
  end

  # Creating a new user (part of signup).
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  # Set up for the signup form.
  def new
    @user = User.new
  end

  # Editing a user.
  def edit
    @user = User.find(by_id)
  end

  # Save edits to a user.
  def update
    @user = User.find(by_id)
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Deleting a user.
  def destroy
    User.find(by_id).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  # Viewing a given user's groups.
  def groups
    @user = User.find(by_id)
    @groups = @user.groups.paginate(page: params[:page])
  end

  # Viewing a given user's events.
  def events
    @user = User.find(by_id)
    @events = @user.events.paginate(page: params[:page])
  end

  private

    # Limit what parameters can be changed through forms.
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                    :password_confirmation)
    end

    # Confirms the correct user
    def correct_user
      @user = User.find(by_id)
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
