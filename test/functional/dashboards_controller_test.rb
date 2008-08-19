require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:dashboards)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_dashboard
    assert_difference('Dashboard.count') do
      post :create, :dashboard => { }
    end

    assert_redirected_to dashboard_path(assigns(:dashboard))
  end

  def test_should_show_dashboard
    get :show, :id => dashboards(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => dashboards(:one).id
    assert_response :success
  end

  def test_should_update_dashboard
    put :update, :id => dashboards(:one).id, :dashboard => { }
    assert_redirected_to dashboard_path(assigns(:dashboard))
  end

  def test_should_destroy_dashboard
    assert_difference('Dashboard.count', -1) do
      delete :destroy, :id => dashboards(:one).id
    end

    assert_redirected_to dashboards_path
  end
end
