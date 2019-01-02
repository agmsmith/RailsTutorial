require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  test "login with empty information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?, "Flash should be empty on second following page."
  end

end
