require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase

  def test_should_show_dashboard
    get :show, :id => dashboards(:one).id
    assert_response :success
  end

end
