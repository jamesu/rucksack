require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_account
    assert_difference('Account.count') do
      post :create, :account => { }
    end

    assert_redirected_to account_path(assigns(:account))
  end

  def test_should_show_account
    get :show, :id => accounts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounts(:one).id
    assert_response :success
  end

  def test_should_update_account
    put :update, :id => accounts(:one).id, :account => { }
    assert_redirected_to account_path(assigns(:account))
  end

  def test_should_destroy_account
    assert_difference('Account.count', -1) do
      delete :destroy, :id => accounts(:one).id
    end

    assert_redirected_to accounts_path
  end
end
