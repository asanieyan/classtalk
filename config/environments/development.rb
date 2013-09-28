# Settings specified here will take precedence over those in config/environment.rb
require 'memcache'
#Please Don't Change development change the production files
#MemcacheServers = [ '10.10.10.107:11211', '10.10.10.103:11212' ]
MemcacheServers = [ '127.0.0.1:11211']#,'127.0.0.1:11212','127.0.0.1:11213' ]
MemcacheOptions = {
   :compression => false,
   :debug => true,
   :namespace => "app-#{ENV['RAILS_ENV']}",
   :readonly => false,
   :urlencode => false
}

#OYCAS_HOST = 'http://dev.oycas.com'
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true 
config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false



#added for exceptionnotifier plugin
