require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "Stock user instance created for testing should pass validity test" do
    assert @user.valid?
  end

  test "name should be present and not blank or empty" do
    @user.name = "     "
    assert_not @user.valid?
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present and not blank or empty" do
    @user.email = "     "
    assert_not @user.valid?
    @user.email = ""
    assert_not @user.valid?
  end

end
