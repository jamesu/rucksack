# Be sure to restart your server when you modify this file

#==
# Copyright (C) 2008 James S Urquhart
# 
# Portions Copyright (C) 2008 2008 Matt Polito
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++


# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '>=2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'ostruct'
::AppConfig = OpenStruct.new()

Rails::Initializer.run do |config|

  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.gem 'gravtastic'
  config.gem 'mojombo-chronic', :lib => 'chronic', :source => 'http://gems.github.com'

  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # config.log_level = :debug

  config.time_zone = 'UTC'
  config.i18n.default_locale = :en

  config.action_controller.session = {
    :session_key => APP_CONFIG['session'],
    :secret      => APP_CONFIG['secret']
  }

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  #config.active_record.observers = :user_observer
end

require_dependency 'rucksack_extras'