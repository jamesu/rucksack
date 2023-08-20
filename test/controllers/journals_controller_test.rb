require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:journals)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_journal
    assert_difference('Journal.count') do
      post :create, :journal => { }
    end

    assert_redirected_to journal_path(assigns(:journal))
  end

  def test_should_show_journal
    get :show, :id => journals(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => journals(:one).id
    assert_response :success
  end

  def test_should_update_journal
    put :update, :id => journals(:one).id, :journal => { }
    assert_redirected_to journal_path(assigns(:journal))
  end

  def test_should_destroy_journal
    assert_difference('Journal.count', -1) do
      delete :destroy, :id => journals(:one).id
    end

    assert_redirected_to journals_path
  end
end
