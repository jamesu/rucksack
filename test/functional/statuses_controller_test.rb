require 'test_helper'

class StatusesControllerTest < ActionController::TestCase

  def test_should_show_status
    get :show, :id => statuses(:one).id
    assert_response :success
  end

  def test_should_update_status
    put :update, :id => statuses(:one).id, :status => { }
    assert_redirected_to status_path(assigns(:status))
  end
end
