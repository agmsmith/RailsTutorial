class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper # So all controllers can use login sessions.

  private

    # Confirms that the user is logged in, shows login page if necessary,
    # useful as a Before filter.
    def logged_in_user
      unless logged_in?
        store_location # Save URL so user can try it again after logging in.
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

end
