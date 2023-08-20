require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end
  
  def test_should_show_tag
    get :show, :id => tags(:one).id
    assert_response :success
  end
end
