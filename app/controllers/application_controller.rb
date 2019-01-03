class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper # So all controllers can use login sessions.
end
