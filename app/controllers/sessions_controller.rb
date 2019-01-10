class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log in the user and redirect to the user's show page.
      log_in user # Adds a session cookie with user's ID number.
      remember user # Add a permanent cookie to skip future logins.
      redirect_to user # Show the user's profile page.
    else # Wrong password or bad e-mail address.
      # Only show the flash on the next page, not on subsequent ones.
      flash.now[:danger] = 'Invalid email & password combination.'
      render 'new'
    end
  end

  def destroy
    if logged_in?
      log_out
      flash[:notice] = "You have been logged out."
    else
      flash[:warning] = "You have already logged out elsewhere!  Now double logged out :-)"
    end
    redirect_to root_url
  end

end
