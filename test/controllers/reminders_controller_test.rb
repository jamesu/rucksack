require 'test_helper'

class RemindersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:reminders)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_reminder
    assert_difference('Reminder.count') do
      post :create, :reminder => { }
    end

    assert_redirected_to reminder_path(assigns(:reminder))
  end

  def test_should_show_reminder
    get :show, :id => reminders(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => reminders(:one).id
    assert_response :success
  end

  def test_should_update_reminder
    put :update, :id => reminders(:one).id, :reminder => { }
    assert_redirected_to reminder_path(assigns(:reminder))
  end

  def test_should_destroy_reminder
    assert_difference('Reminder.count', -1) do
      delete :destroy, :id => reminders(:one).id
    end

    assert_redirected_to reminders_path
  end
end
