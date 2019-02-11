class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :index, :update, :destroy]
  before_action :correct_user, only: [:edit, :update] # Side effect: sets @user
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new # First part of making a new user, show a web form.
    @user = User.new
  end

  def create # Second part of making a new user, store stuff from web form.
    @user = User.new(user_params) # Get cleaned up user input parameters.
    if @user.save
      log_in @user # Auto-login newly created users, saves ID in the session.
      # flash shows up in rendering the following page, hidden in session.
      flash[:success] = "Welcome to the Sample Application, #{@user.name}!"
      # Handle a successful save, new user created!  Show their profile page.
      redirect_to @user # Equivalent to user_url(@user), ends up as /users/123
    else
      render 'new'
    end
  end

  def destroy
    destroyee = User.find(params[:id]) # Raises ActiveRecord::RecordNotFound if not found.
    destroyeeName = destroyee.name
    destroyee.destroy
    flash[:success] = "User \"#{destroyeeName}\" deleted."
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated."
      redirect_to @user
    else # Try again, reshow the form, with field error messages in red.
      render 'edit'
    end
  end

  private

    # Filter out unwanted parameters, from web form.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters.

    # Confirms that the user is logged in.
    def logged_in_user
      unless logged_in?
        store_location # Save URL so user can try it again after logging in.
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms that the correct user is logged in (same ID specified by both
    # the session cookie and the URL used to edit a User).
    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        flash[:danger] = "Mismatch between logged in user and user being edited.  Please stop hacking URLs, and play nice!"
        redirect_to root_url
      end
    end

    # Confirms that the logged in user is an administrator.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
