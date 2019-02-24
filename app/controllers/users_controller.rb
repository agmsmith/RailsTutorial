class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :index, :update, :destroy]
  before_action :correct_user, only: [:edit, :update] # Side effect: sets @user
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new # First part of making a new user, show a web form.
    @user = User.new
  end

  def create # Second part of making a new user, store stuff from web form,
  # send an activation e-mail to check that the address is correct.
    @user = User.new(user_params) # Get cleaned up user input parameters.
    if @user.save
      @user.send_activation_email
      # flash shows up in rendering the following page, hidden in session.
      flash[:info] = "Please check your email (#{@user.email}) to activate your account."
      redirect_to root_url
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

    # Before filters.  Also see parent class for more of them.

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
