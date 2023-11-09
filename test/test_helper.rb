ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "../lib/authenticated_test_helper"

if (ENV["USE_JUINT"]||'0').to_i == 1 then
  require 'minitest/reporters'
  Minitest::Reporters.use! [Minitest::Reporters::JUnitReporter.new]
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures %w{users accounts albums emails album_pictures pages uploaded_files separators journals list_items lists tags reminders page_slots notes application_logs statuses}

  # Add more helper methods to be used by all tests here...
end
