require 'test_helper'
  
class AccountsControllerTest < ActionController::TestCase

  def test_should_show_account
    get :show
    assert_response :success
  end

  def test_should_update_account
    put :update, :id => accounts(:one).id, :account => { }
    assert_redirected_to account_path(assigns(:account))
  end
end
