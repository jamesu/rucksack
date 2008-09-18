require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_status
    assert_difference('Status.count') do
      post :create, :status => { }
    end

    assert_redirected_to status_path(assigns(:status))
  end

  def test_should_show_status
    get :show, :id => statuses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => statuses(:one).id
    assert_response :success
  end

  def test_should_update_status
    put :update, :id => statuses(:one).id, :status => { }
    assert_redirected_to status_path(assigns(:status))
  end

  def test_should_destroy_status
    assert_difference('Status.count', -1) do
      delete :destroy, :id => statuses(:one).id
    end

    assert_redirected_to statuses_path
  end
end
