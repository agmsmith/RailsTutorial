require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael) # Get it from the Fixture/test database users.yml.
  end

  test "login with empty information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?, "Flash should be empty on second following page."
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    assert flash.empty?, "Flash should be empty after successful login."
    delete logout_path
    assert_not is_logged_in?, "Should be logged out after hitting the logout page."
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
    # Simulate user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    # Log in with the option to set the permanent login cookie.
    log_in_as(@user, remember_me: '1')
    # Verify that same random string token is in the cookie and Users instance.
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test "login without remembering" do
    # Log in with the option to set the permanent login cookie.
    log_in_as(@user, remember_me: '1')
    # Log in again and verifiy that the cookie is deleted.
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token'] # :remember_token malfunctions here.
  end

end
