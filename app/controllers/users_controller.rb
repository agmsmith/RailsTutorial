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
      # Handle a successful save.
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
