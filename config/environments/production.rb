# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
MemcacheServers = [ '127.0.0.1:11211',
                    "127.0.0.1:11212",
                    "127.0.0.1:11213",
                    "127.0.0.1:11214",
                    "127.0.0.1:11215",
                    "127.0.0.1:11216",
                    "127.0.0.1:11217"
                     ]
MemcacheOptions = {
   :compression => false,
   :debug => false,
   :namespace => "app-#{ENV['RAILS_ENV']}",
   :readonly => false,
   :urlencode => false
}
config.cache_classes = true 

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

require 'analyzer_tools/syslog_logger'
config.logger = SyslogLogger.new
config.logger.level = Logger::INFO
