class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log in the user and redirect to the user's show page.
    else # Wrong password or bad e-mail address.
      # Only show the flash on the next page, not on subsequent ones.
      flash.now[:danger] = 'Invalid email & password combination.'
      render 'new'
    end
  end

  def destroy
  end

end
