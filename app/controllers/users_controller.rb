class UsersController < ApplicationController

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

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else # Try again, reshow the form, with field error messages in red.
      render 'edit'
    end
  end

  private

    def user_params # Filter out unwanted parameters, from web form.
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
