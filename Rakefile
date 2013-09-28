# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require(File.join(File.dirname(__FILE__), 'config', 'boot'))

Dir.chdir(RAILS_ROOT)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'lib/rake_util.rb'
include Kernel::Confirmation
@environment_loaded = false

#task :environment do
#  return
#  if not @environment_loaded   
#    require(File.join(File.dirname(__FILE__), 'config', 'environment'))      
##  require 'lib/mysql_bigint.rb'  
#  end
#end

#namespace :db do 
#  namespace :schema do 
#    namespace :load=>:environment do 
#        fail "can't do this in the production environment" if (ENV['RAILS_ENV'] || "development") == "production"
#    end
#  end
#end
#namespace :db do
#    namespace :loaddummy do
##      require(File.join(File.dirname(__FILE__),'vendor/drbs','school_support'))
#      task :create_schema_from_sql_file do |t|
##          if RAILS_ENV == 'development'
##            puts  `mysql -u root  -p123 schoolapp_development <db/create.sql`
##          elsif RAILS_ENV == 'production'
##            puts `mysql -u root -p schoolapp_production<db/create.sql`
##          end
#            puts `mysql -u root -p123 schoolapp_development<db/create.sql`          
#      
#      end
#      desc "creates a profile image for each student"
#      task :pimages do |t|
#          dir = "C:/Documents and Settings/asanieya/My Documents/My Pictures/ariane's trip"
#          image_files = []
#          Dir.entries(dir).each do |f|
#              if File.extname(f) == ".jpg"
#                  image_files << File.join(dir,f)
#              end
#          
#          end
#          Student.find(:all).each_with_index do |student,i|
#                student.profile_picture= File.open(image_files[i % 31],"rb")
#          end
#      
#      end
#      desc "load up dummy data into db"      
#      task :data => :create_schema_from_sql_file do |t|
##          Rake::Task["db:fixtures:load"].invoke
##          admin = Admin.new(:confirmed=>:y,:first_name=>'Arash',:last_name=>'Sanieyan',:email=>'asanieyan@gmail1.com')
##          admin.password= "123123123"
##          admin.save
##          File.open('mimes.txt','r') do |f|
##                mimes = f.read       
##                mimes.split("\n").each do |_|
##                  ext,type = _.split(" \t")  
##                  FileMime.create(:extension=>ext,:mime_type=>type)                
##                end
##          end
##          require 'network.rb'
##          c = Country.create(:name=>"canada")
##          s = SubRegion.create(:name=>"british columbia",:country_id=>c.id)          
##          Network.create(:name=>"vancouver",:sub_region_id=>s.id)
##          Network.create(:name=>"north vancouver",:sub_region_id=>s.id) 
##          require 'yaml'    
##          ReportReason.load_from_yml(YAML::load_file('lib/reporting/reports.yml'))
##          s = School.create_from_yml(YAML::load_file('lib/school/schools/sfu/sfu.yml'))                      
##          s.active = :y
##          s.save
##          s = School.create_from_yml(YAML::load_file('vendor/drbs/cap_parsed.yml'))  
##          s.active = :y
##          s.save
#          #for each school add random students 
#          names = (File.new('namefile.txt',"r").read).split(" ")              
#          School.find(:all).each do |school|
#            15.times do |i|
#                if i == 0
#                  first_name = 'kim-anh'
#                  last_name = 'duong'
#                  username = 'kim0732@gmail.com'
#                else
#                  first_name = names.delete_at(i).downcase  rescue "smith#{rand(1000)}" 
#                  last_name = names.delete_at(i+1).downcase rescue "johnson#{rand(1000)}"                   
#                  username = (first_name + "_" + last_name).gsub(/\s/,'_') + "@" + school.email_domain
#                end
#                s = Student.create_new(first_name,last_name,username,'123',school)
#                s.guid = i + 900000000000000000
#                s.save
#            end              
#            break;
#          end    
#      end
#   end
#end
#
#def uploaded_file(path, content_type="application/octet-stream", filename=nil)
#  filename ||= File.basename(path)
#  #t = Tempfile.new(filename)
#  t = File.open(path,"rb")
#  # FileUtils.copy_file(path, t.path)
##  puts t.size
##  puts t.read.size
##  t.pos = 0
#  (class << t; self; end;).class_eval do
#    alias local_path path
#    define_method(:original_filename) { filename }
#    define_method(:content_type) { content_type }
#  end
#  return t
#end
#task "note:file" do |t|
#    require(File.join(File.dirname(__FILE__), 'config', 'environment'))    
#    require(File.join(File.dirname(__FILE__), 'app/controllers', 'application'))    
##    require(File.join(File.dirname(__FILE__), 'app/controllers', 'application'))    
#    params = {:noteid=>"816717565610925385",:upload_files=>{"f1"=>uploaded_file("c:/temp/m.zip")}}
#    me = Student.find(1)
#    
#end

