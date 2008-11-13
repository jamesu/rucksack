require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase

  def test_should_show_dashboard
    # Main user shoul
    
    login_as :main_user
    get :show
    assert_response :success
    
    login_as :normal_user
    get :show
    assert_response :success
    
    login_as :guest_user
    get :show
    assert_response 200
  end

end
