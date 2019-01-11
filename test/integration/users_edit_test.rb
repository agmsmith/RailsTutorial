require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael) # Get it from the Fixture/test database users.yml.
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {
        name: "",
        email: "foo@invalid",
        password: "foo",
        password_confirmation: "bar" } }
    assert_template 'users/edit'
    # Verify that there are N error messages.
    N = 4
    assert_select "div#error_explanation" do
      assert_select "div.alert", {count: 1, text: "The form contains #{N} errors."}
      assert_select "ul" do
        assert_select "li", count: N
      end
    end
  end

  test "successful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: {
        name: name,
        email: email,
        password: "",
        password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

end
