ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'lib/authenticated_test_helper'

class ActiveSupport::TestCase
  fixtures :all

  include AuthenticatedTestHelper
end
