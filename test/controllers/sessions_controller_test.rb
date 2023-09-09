require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'
require 'nokogiri'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :users

  def test_should_login_and_redirect
    post :create, params: {login: 'test', password: 'testing'}
    assert session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, params: {login: 'test', password: 'bad password'}
    assert_nil session[:user_id]
    assert_response :success
  end

  def test_should_logout
    login_as :main_user
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    cookies[:auth_token] = nil
    post :create, params: {login: 'test', password: 'testing', remember_me: "1"}
    assert_not_nil cookies[:auth_token]
  end

  def test_should_not_remember_me
    cookies[:auth_token] = nil
    post :create, params: {login: 'test', password: 'testing', remember_me: "0"}
    puts cookies[:auth_token]
    assert cookies[:auth_token].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :main_user
    get :destroy
    assert cookies[:auth_token].blank?
  end

  def test_should_login_with_cookie
    users(:main_user).remember_me
    users(:main_user).save!

    cookies[:auth_token] = cookie_for(:main_user)
    get :new
    assert_response :success

    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:main_user).remember_me
    users(:main_user).update_attribute :remember_token_expires_at, 5.minutes.ago
    cookies[:auth_token] = cookie_for(:main_user)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:main_user).remember_me
    cookies[:auth_token] = 'invalid_auth_token'
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    
    def cookie_for(user)
      users(user).remember_token
    end
end
