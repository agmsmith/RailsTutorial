require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup doesn't create new user" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_template 'users/new'
  end

  test "empty signup has enough error messages" do
    get signup_path
    post signup_path, params: { user: { name: "  " }}
    N = 4
    # Verify that there are N error messages.
    assert_select "div#error_explanation" do
      # assert_select "div.alert" do |alertdiv| p alertdiv.inner_text.squish end
      assert_select "div.alert", {count: 1, text: "The form contains #{N} errors."}
      assert_select "ul" do
        assert_select "li", count: N
      end
    end
  end

  test "signup page should submit to the signup page URL" do
    get signup_path
    assert_select "form[action=?]", signup_path
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {
        name: "Example User",
        email: "user@example.com",
        password: "password",
        password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user) # Sneak data out of @user in the controller.
    follow_redirect!
    assert_select "div.alert-info", {count: 1,
      text: "Please check your email (#{user.email}) to activate your account."}
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token.
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong e-mail (it is case sensitive at this stage).
    get edit_account_activation_path(user.activation_token, email: user.email.upcase)
    assert_not is_logged_in?
    # Valid activation token and e-mail.
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?, "Internal session state should be logged in."
    assert flash.count == 1,
      "Should be one item in the flash hash, have #{flash.count}."
  end

end
