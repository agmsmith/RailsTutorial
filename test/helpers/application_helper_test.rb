require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper function" do
    assert_equal full_title, "Ruby on Rails Tutorial Sample Application"
    assert_equal full_title("Grable"), "Grable | Ruby on Rails Tutorial Sample Application"
  end
end
