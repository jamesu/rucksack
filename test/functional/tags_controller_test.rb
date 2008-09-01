require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tag
    assert_difference('Tag.count') do
      post :create, :tag => { }
    end

    assert_redirected_to tag_path(assigns(:tag))
  end

  def test_should_show_tag
    get :show, :id => tags(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => tags(:one).id
    assert_response :success
  end

  def test_should_update_tag
    put :update, :id => tags(:one).id, :tag => { }
    assert_redirected_to tag_path(assigns(:tag))
  end

  def test_should_destroy_tag
    assert_difference('Tag.count', -1) do
      delete :destroy, :id => tags(:one).id
    end

    assert_redirected_to tags_path
  end
end
