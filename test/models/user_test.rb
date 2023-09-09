require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Token should change when password changes 
  # (even with new password)
  def test_token
    user = users(:main_user)
    
    orig_token = user.twisted_token
    
    user.password = 'testing'
    assert user.save
    
    user = users(:main_user)
    new_token = user.twisted_token
    
    assert_not_equal new_token, orig_token
  end
  
  # Passwords on both users should be valid
  def test_password
    main_user = users(:main_user)
    normal_user = users(:normal_user)
    
    assert_equal true, main_user.valid_password('testing')
    assert_equal false, main_user.valid_password('goop')
    
    assert_equal true, normal_user.valid_password('testing')
    assert_equal false, normal_user.valid_password('goop')
  end
  
  # Permissions should work properly
  def test_permissions
    main_user = users(:main_user)
    normal_user = users(:normal_user)
    guest_user = users(:guest_user)

    anonymous_user = User.new(display_name: 'Anonymous')
    anonymous_user.username = 'anonymous'
    anonymous_user.is_anonymous = true
    
    # sanity check
    assert_equal true, main_user.is_admin
    assert_equal false, normal_user.is_admin
    assert_equal false, guest_user.is_admin
    
    # can_be_created_by
    assert_equal true, User.can_be_created_by(main_user)
    assert_equal false, User.can_be_created_by(normal_user)
    assert_equal false, User.can_be_created_by(guest_user)
    assert_equal false, User.can_be_created_by(anonymous_user)
    
    # can_be_edited_by
    assert_equal true, main_user.can_be_edited_by(main_user)
    assert_equal false, main_user.can_be_edited_by(normal_user)
    assert_equal false, main_user.can_be_edited_by(guest_user)
    
    
    assert_equal false, main_user.can_be_edited_by(anonymous_user)
    
    assert_equal true, normal_user.can_be_edited_by(main_user)
    assert_equal true, normal_user.can_be_edited_by(normal_user)
    assert_equal false, normal_user.can_be_edited_by(guest_user)
    assert_equal false, normal_user.can_be_edited_by(anonymous_user)
    
    assert_equal true, guest_user.can_be_edited_by(main_user)
    assert_equal false, guest_user.can_be_edited_by(normal_user)
    assert_equal false, guest_user.can_be_edited_by(guest_user)
    assert_equal false, guest_user.can_be_edited_by(anonymous_user)
    
    # can_be_deleted_by
    assert_equal false, main_user.can_be_deleted_by(main_user)
    assert_equal false, main_user.can_be_deleted_by(normal_user)
    assert_equal false, main_user.can_be_deleted_by(guest_user)
    assert_equal false, main_user.can_be_deleted_by(anonymous_user)
    
    assert_equal true, normal_user.can_be_deleted_by(main_user)
    assert_equal false, normal_user.can_be_deleted_by(normal_user)
    assert_equal false, normal_user.can_be_deleted_by(guest_user)
    assert_equal false, normal_user.can_be_deleted_by(anonymous_user)
    
    assert_equal true, guest_user.can_be_deleted_by(main_user)
    assert_equal false, guest_user.can_be_deleted_by(normal_user)
    assert_equal false, guest_user.can_be_deleted_by(guest_user)
    assert_equal false, guest_user.can_be_deleted_by(anonymous_user)
    
    # can_be_seen_by
    assert_equal true, main_user.can_be_seen_by(main_user)
    assert_equal true, main_user.can_be_seen_by(normal_user)
    assert_equal false, main_user.can_be_seen_by(guest_user)
    assert_equal false, main_user.can_be_seen_by(anonymous_user)
    
    assert_equal true, normal_user.can_be_seen_by(main_user)
    assert_equal true, normal_user.can_be_seen_by(normal_user)
    assert_equal false, normal_user.can_be_seen_by(guest_user)
    assert_equal false, normal_user.can_be_seen_by(anonymous_user)
    
    assert_equal true, guest_user.can_be_seen_by(main_user)
    assert_equal true, guest_user.can_be_seen_by(normal_user)
    assert_equal false, guest_user.can_be_seen_by(guest_user)
    assert_equal false, guest_user.can_be_seen_by(anonymous_user)
    
    # can_add_favourite
    assert_equal true, main_user.can_add_favourite(main_user)
    assert_equal false, main_user.can_add_favourite(normal_user)
    assert_equal false, main_user.can_add_favourite(guest_user)
    assert_equal false, main_user.can_add_favourite(anonymous_user)
    
    assert_equal true, normal_user.can_add_favourite(main_user)
    assert_equal true, normal_user.can_add_favourite(normal_user)
    assert_equal false, normal_user.can_add_favourite(guest_user)
    assert_equal false, normal_user.can_add_favourite(anonymous_user)
    
    assert_equal true, guest_user.can_add_favourite(main_user)
    assert_equal false, guest_user.can_add_favourite(normal_user)
    assert_equal false, guest_user.can_add_favourite(guest_user)
    assert_equal false, guest_user.can_add_favourite(anonymous_user)
    
    # pages_can_be_seen_by
    assert_equal true, main_user.pages_can_be_seen_by(main_user)
    assert_equal false, main_user.pages_can_be_seen_by(normal_user)
    assert_equal false, main_user.pages_can_be_seen_by(guest_user)
    assert_equal false, main_user.pages_can_be_seen_by(anonymous_user)
    
    assert_equal true, normal_user.pages_can_be_seen_by(main_user)
    assert_equal true, normal_user.pages_can_be_seen_by(normal_user)
    assert_equal false, normal_user.pages_can_be_seen_by(guest_user)
    assert_equal false, normal_user.pages_can_be_seen_by(anonymous_user)
    
    assert_equal true, guest_user.pages_can_be_seen_by(main_user)
    assert_equal false, guest_user.pages_can_be_seen_by(normal_user)
    assert_equal false, guest_user.pages_can_be_seen_by(guest_user)
    assert_equal false, guest_user.pages_can_be_seen_by(anonymous_user)
    
    # reminders_can_be_seen_by
    assert_equal true, main_user.reminders_can_be_seen_by(main_user)
    assert_equal false, main_user.reminders_can_be_seen_by(normal_user)
    assert_equal false, main_user.reminders_can_be_seen_by(guest_user)
    assert_equal false, main_user.reminders_can_be_seen_by(anonymous_user)
    
    assert_equal true, normal_user.reminders_can_be_seen_by(main_user)
    assert_equal true, normal_user.reminders_can_be_seen_by(normal_user)
    assert_equal false, normal_user.reminders_can_be_seen_by(guest_user)
    assert_equal false, normal_user.reminders_can_be_seen_by(anonymous_user)
    
    assert_equal true, guest_user.reminders_can_be_seen_by(main_user)
    assert_equal false, guest_user.reminders_can_be_seen_by(normal_user)
    assert_equal false, guest_user.reminders_can_be_seen_by(guest_user)
    assert_equal false, guest_user.reminders_can_be_seen_by(anonymous_user)
    
    # journals_can_be_seen_by
    assert_equal true, main_user.journals_can_be_seen_by(main_user)
    assert_equal false, main_user.journals_can_be_seen_by(normal_user)
    assert_equal false, main_user.journals_can_be_seen_by(guest_user)
    assert_equal false, main_user.journals_can_be_seen_by(anonymous_user)
    
    assert_equal true, normal_user.journals_can_be_seen_by(main_user)
    assert_equal true, normal_user.journals_can_be_seen_by(normal_user)
    assert_equal false, normal_user.journals_can_be_seen_by(guest_user)
    assert_equal false, normal_user.journals_can_be_seen_by(anonymous_user)
    
    assert_equal true, guest_user.journals_can_be_seen_by(main_user)
    assert_equal false, guest_user.journals_can_be_seen_by(normal_user)
    assert_equal false, guest_user.journals_can_be_seen_by(guest_user)
    assert_equal false, guest_user.journals_can_be_seen_by(anonymous_user)
  end
end
