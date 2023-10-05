# Load the Rails application.
require_relative "application"

# load app_config.yml
require 'yaml'
APP_CONFIG = YAML.load_file(::Rails.root.to_s + "/config/app_config.yml")

# Initialize the Rails application.
Rails.application.initialize!
