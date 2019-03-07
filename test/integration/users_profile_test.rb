require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display including microposts" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title("Showing: " + @user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match "(#{@user.microposts.count})", response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "profile display follower counts" do
    [:lana, :malory, :user_1].each do |username|
      user = users(username)
      get user_path(user)
      assert_select 'strong#following',
        { :count => 1, :text => "#{user.following.count}"},
        "#{user.name} should be following #{user.following.count} users"
      assert_select 'strong#followers',
        { :count => 1, :text => "#{user.followers.count}"},
        "#{user.name} should have #{user.followers.count} followers"
    end
  end

end
