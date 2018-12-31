require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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
    N = 6
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

  test "valid signup should create a new user" do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: {
        user: {
          name: "Rails Tutorial",
          email: "example@railstutorial.org",
          password: "foobar",
          password_confirmation: "foobar"
        }
      }
    end
    follow_redirect!
    assert_template 'users/show'
    assert flash.count == 1,
      "Should be one item in the flash hash, have #{flash.count}."
    assert_select "div.alert-success", {count: 1,
      text: "Welcome to the Sample Application, Rails Tutorial!"}
  end

end
