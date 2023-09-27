require 'application_system_test_case'

class QunitSystemTest < ApplicationSystemTestCase
  test 'run Jest tests' do
    
    visit java_script_test_runner_url
    assert_equal '✔ Test Suite', evaluate_script("document.title")

  end
end
