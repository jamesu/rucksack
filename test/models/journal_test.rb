require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  fixtures :accounts, :users, :journals

  def test_order
    user1 = users(:main_user)
    user2 = users(:normal_user)
    
    assert_equal ["Moo", "Bleh bleh bleh bleh"], user1.journals.sorted_list.map(&:content)
    assert_equal ["Woof", "Bla bla bla bla"],    user2.journals.sorted_list.map(&:content)
  end
  
end
