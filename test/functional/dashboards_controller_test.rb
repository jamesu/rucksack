require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase

  def test_should_show_dashboard_main
    login_as :main_user
    get :show
    assert_response :success
  end

  def test_should_show_dashboard_normal
    login_as :normal_user
    get :show
    assert_response :success
  end

  def test_should_show_dashboard_guest
    login_as :guest_user
    get :show
    assert_response :redirect
  end

end
