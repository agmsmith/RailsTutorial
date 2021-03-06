require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
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

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    # Maximum database string size is often 255 characters.  So we want to
    # reject e-mails that are longer than that.
    @user.email = "a" * 244 + "@example.com"
    assert @user.email.length >= 256
    assert_not @user.valid?
  end

  test "email should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
      first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
      foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    # Should be case insensitive duplicate rejection too.
    duplicate_user.email = duplicate_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be converted to lower case upon saving to database" do
    mixed_name = "Test@Somewhere.com"
    @user.email = mixed_name
    assert @user.email == mixed_name
    @user.save
    @user.reload
    assert_not_equal mixed_name, @user.email,
      "Name should be different from the original #{mixed_name} when saving."
    assert_equal mixed_name.downcase, @user.email,
      "Should have become lower case."
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil remember_digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    userA = users(:user_10)
    userB = users(:user_11)
    assert_not userA.following?(userB)
    assert_not userB.following?(userA)
    assert_not userB.followers.include?(userA)
    assert_not userA.followers.include?(userB)
    userA.follow(userB)
    assert userA.following?(userB)
    assert_not userB.following?(userA)
    assert userB.followers.include?(userA)
    assert_not userA.followers.include?(userB)
    userA.unfollow(userB)
    assert_not userA.following?(userB)
    assert_not userB.following?(userA)
    assert_not userB.followers.include?(userA)
    assert_not userA.followers.include?(userB)
  end

  test "feed should have the posts of followers and self but nobody else" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    # mfl, mfma, lfm, afm
    # Posts from followed user lana; michael follows lana.
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following), "Should have Lana's posts since she's being followed."
    end
    # Posts from self should be included.
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self), "Should have own posts."
    end
    # Posts from an unfollowed user shouldn't be there.
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed), "Should not have unfollowed people's posts."
    end
  end

end
