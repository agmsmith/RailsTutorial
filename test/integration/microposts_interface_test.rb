require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination' # Michael has pages of microposts.
    assert_select 'input[type=file]'
    # Invalid submission, content length should be more than 0 characters.
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/files/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: {
        content: content,
        picture: picture } }
    end
    micropost = assigns(:micropost) # Rip @microposts from the controller, valid after create() done.
    assert micropost.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit different user, shouldn't be any delete links.
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost counter on home page sidebar" do
    log_in_as(@user)
    get root_path
    assert_select 'section.user_info', /#{@user.microposts.count} microposts/
    # User with zero microposts
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    # One micropost, singular wording
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "<span>1 micropost</span>", response.body
  end

end
