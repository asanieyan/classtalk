# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present

#RAILS_GEM_VERSION = '1.1.6'
#RAILS_GEM_VERSION = '1.2.1'
#RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|
 
  # Settings in config/environments/* take precedence those specified here  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]
  #action mailer development setting   
  # Add additional load paths for your own custom dirs  
  # for some reason  subdirectories of model directory doesn't get loaded with rails 1.2.1
  # here i will load every subdirectory of the model directory 

#  Dir.open("#{RAILS_ROOT}/app/models").each do |entry|
#      file_path = File.join("#{RAILS_ROOT}/app/models",entry)
#      if File.directory? file_path and entry.match(/^[^.]/)
#          config.load_paths  <<   file_path + "/"
#
#      end
#
#  end
#  
#  config.load_paths << 'lib/facebookbot/facebook_bot/facebook_bot.rb'
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug


  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session_store = :mem_cache_store
#  config.action_controller.fragment_cache_store = :mem_cache_store, memcache_servers, memcache_options
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql
  
  # Activate observers that should always be running
#   config.active_record.observers = :cacher, :garbage_collector
 
  # Make Active Record use UTC-base instead of local time
   config.active_record.default_timezone = :utc
   begin
     require_gem 'tzinfo' # Use tzinfo library to convert to and from the users timezone
   rescue
   
   end
   ENV['TZ'] = 'UTC' # This makes Time.now return time in UTC   

  # See Rails::Configuration for more options
  
end

ActionMailer::Base.server_settings = {
  :address  => "shawmail.vc.shawcable.net",
  :port  => 25, 
  :domain  => 'www.mydomain.com'
} 
#ActionMailer::Base.server_settings = {
#  :address  => "smtp.emailsrvr.com",
#  :port  => 25, 
#  :user_name => "kim@oycas.com",
#  :password=>"v3j7n1v3j7n1",
#  :authentication=>:login,
#  :domain  => 'www.oycas.com'
#} 
#require 'cached_model'
  
  CACHE = MemCache.new(MemcacheServers,MemcacheOptions)
  ActionController::Base.session_options[:cache] = CACHE
  require 'cached_model' 
  require_gem 'json'
  require 'lib/rails_1.2_compatibilities.rb'
  require 'lib/classtalk/init.rb'
  require 'lib/rfacebook/rfacebook.rb'
  require 'yaml'
  require 'hpricot'
  Dir["app/models/*.rb"].each do |rb_file|
    require rb_file rescue next
  end  
begin
  ExceptionNotifier.exception_recipients = %w(asanieyan@oycas.com sholinaty@oycas.com bugs@oycas.com) 
rescue 

end

