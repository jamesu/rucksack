# load app_config.yml
require 'yaml'
APP_CONFIG = YAML.load_file(RAILS_ROOT + "/config/app_config.yml")