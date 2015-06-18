class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def index
    @users = User.order(hours: :desc)
  end

  def show
    @user = User.find(by_id)
  end

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

  def new
    @user = User.new
  end

  def edit
    @user = User.find(by_id)
  end

  def update
    @user = User.find(by_id)
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(by_id).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def groups
    @user = User.find(by_id)
    @groups = @user.groups
  end

  def events
    @user = User.find(by_id)
    @events = @user.events
  end

  private

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
