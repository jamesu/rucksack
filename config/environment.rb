# Be sure to restart your server when you modify this file

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

  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # config.log_level = :debug

  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_rucksack_session',
    :secret      => 'ccf6416710c9893c2233dd0550a70f074660301de000dc4e2c890bf97faf4e7400647635198a88d5aa89e5e38eafc7ea96fb6bc0bcfd87eac3ce5426dc73ab3b'
  }

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  #config.active_record.observers = :user_observer
end

Globalite.locale = "en-US".to_sym
