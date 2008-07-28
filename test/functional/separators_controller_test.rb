require 'test_helper'

class SeparatorsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:separators)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_separator
    assert_difference('Separator.count') do
      post :create, :separator => { }
    end

    assert_redirected_to separator_path(assigns(:separator))
  end

  def test_should_show_separator
    get :show, :id => separators(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => separators(:one).id
    assert_response :success
  end

  def test_should_update_separator
    put :update, :id => separators(:one).id, :separator => { }
    assert_redirected_to separator_path(assigns(:separator))
  end

  def test_should_destroy_separator
    assert_difference('Separator.count', -1) do
      delete :destroy, :id => separators(:one).id
    end

    assert_redirected_to separators_path
  end
end
