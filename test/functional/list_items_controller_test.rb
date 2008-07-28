require 'test_helper'

class ListItemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:list_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_list_item
    assert_difference('ListItem.count') do
      post :create, :list_item => { }
    end

    assert_redirected_to list_item_path(assigns(:list_item))
  end

  def test_should_show_list_item
    get :show, :id => list_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => list_items(:one).id
    assert_response :success
  end

  def test_should_update_list_item
    put :update, :id => list_items(:one).id, :list_item => { }
    assert_redirected_to list_item_path(assigns(:list_item))
  end

  def test_should_destroy_list_item
    assert_difference('ListItem.count', -1) do
      delete :destroy, :id => list_items(:one).id
    end

    assert_redirected_to list_items_path
  end
end
