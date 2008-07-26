require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_list
    assert_difference('List.count') do
      post :create, :list => { }
    end

    assert_redirected_to list_path(assigns(:list))
  end

  def test_should_show_list
    get :show, :id => lists(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => lists(:one).id
    assert_response :success
  end

  def test_should_update_list
    put :update, :id => lists(:one).id, :list => { }
    assert_redirected_to list_path(assigns(:list))
  end

  def test_should_destroy_list
    assert_difference('List.count', -1) do
      delete :destroy, :id => lists(:one).id
    end

    assert_redirected_to lists_path
  end
end
