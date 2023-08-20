require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:notes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_note
    assert_difference('Note.count') do
      post :create, :note => { }
    end

    assert_redirected_to note_path(assigns(:note))
  end

  def test_should_show_note
    get :show, :id => notes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => notes(:one).id
    assert_response :success
  end

  def test_should_update_note
    put :update, :id => notes(:one).id, :note => { }
    assert_redirected_to note_path(assigns(:note))
  end

  def test_should_destroy_note
    assert_difference('Note.count', -1) do
      delete :destroy, :id => notes(:one).id
    end

    assert_redirected_to notes_path
  end
end
