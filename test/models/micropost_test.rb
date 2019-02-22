require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "micropost should be valid" do
    assert @micropost.valid?
  end

  test "micropost should have a user id" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present, blanks don't count" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

end
