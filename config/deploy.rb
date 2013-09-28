# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

require 'mongrel_cluster/recipes'
require 'lib/rake_util.rb'
extend Kernel::Confirmation

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "classtalk"
set :repository, "http://24.86.0.167:3921/repos/classtalk/trunk" #"http://svn.yourhost.com/#{application}/trunk"
#server =  "10.10.10.103"
server =  "216.187.103.55"
# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, server
role :app, server
role :db,  server,:primary => true  
#role :db,  "db02.example.com", "db03.example.com"

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
 set :deploy_to, "/var/www/#{application}" # defaults to "/u/apps/#{application}"
# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)

#set :user, "root"
#set :password ,"fuxormynuggets"
set :user, "mongrel"
if server == "10.10.10.103"
  #set :password ,"duck51ck"
  #ssh_options[:port] = 25
else
  ssh_options[:port] = 25678
end



# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepassword\n" if out =~ /^Enter password:/
  end
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).
def setup_transaction_to_test
   ssh_options[:port] = nil  
   roles[:app].first.host = roles[:db].first.host = roles[:web].first.host =  "10.10.10.103"
end
desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
  end
  restart
  enable_web
end

task :classtalk_setup do    
    return unless confirm("setting up in #{roles[:web].first.host} ? ")
    transaction do
      sudo    "mkdir #{deploy_to}" 
      sudo    "chown -R mongrel:mongrel #{deploy_to}"
      setup
    end
end
task :classtalk_deploy do
    return unless confirm("deploying to #{roles[:web].first.host} ? ")
    transaction do      
      long_deploy
      run <<-CMD          
          ln -nfs /var/log/oycas/production.log #{shared_path}/log/production.log
          ln -nfs  #{shared_path}/user_data  #{release_path}/user_data
      CMD
    end    
end
task :classtalk_restart do
  disable_web
  restart
  enable_web
end
task :classtalk_update do
   return unless confirm("updating to #{roles[:web].first.host} ? ")
   update_current
end
task :update do
   return unless confirm("updating to #{roles[:web].first.host} ? ")
   update_current
end
#task :test_drop_db do 
#  setup_transaction_to_test
#  run "mysqladmin drop classtalk
#end
task :test_setup do 
  setup_transaction_to_test   
  classtalk_setup 
end
task :test_sym do 
  setup_transaction_to_test   
  symlink
end
task :test_deploy do 
  setup_transaction_to_test
  classtalk_deploy  
end
task :test_update do 
  setup_transaction_to_test
  classtalk_update
end
desc <<-DESC
Disable the web server by writing a "maintenance.html" file to the web
servers. The servers must be configured to detect the presence of this file,
and if it is present, always display it instead of performing the request.
DESC
task :disable_web, :roles => :web do
  on_rollback { delete "#{shared_path}/system/maintenance.html" }  
  maintenance = render((File.join(File.dirname(__FILE__),"../lib/maintenance.rhtml")), :deadline => ENV['UNTIL'],
    :reason => ENV['REASON'])
  put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
end


