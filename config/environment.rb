# Load the rails application
require File.expand_path('../application', __FILE__)

# load app_config.yml
require 'yaml'
APP_CONFIG = YAML.load_file(RAILS_ROOT + "/config/app_config.yml")

# Initialize the rails application
Rucksack::Application.initialize!
