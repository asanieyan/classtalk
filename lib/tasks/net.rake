namespace :net do 
    task :assess do 
        loaded = []
        notloaded = []
        Dir["lib/net_support/*"].each do |dir|         
          name = File.basename(dir)
          next if name == "archive"
          name2 = "   " + name
          if File.exists? File.join(dir, name + ".html") 
            loaded.push(name2) 
          elsif File.exists? File.join(dir, name + ".rb")
            notloaded.push(name2)
          end
        end
        File.open("lib/net_support/status.txt","w") do |f|
            f << "Schools that have html test file (#{loaded.size}):\n"
            f << loaded.join("\n")
            f << "\nSchools that doesn't have html test file  (#{notloaded.size}):\n"
            f << notloaded.join("\n")
        end
            
    end
    task :unarchive do 
      school  = $argv[:n].first.to_s      
      src = "lib/net_support/archive/#{school}"      
      dest = "lib/net_support/#{school}" 
      puts `svn up`
      puts `svn move #{src} #{dest}`
      puts `svn ci -m 'unarchive #{school}'`
    end
    task :archive do     
       puts `svn up`
       schools = $argv[:n].first.to_s.split(",")
       schools.each do |school|
           src = "lib/net_support/#{school.downcase}"
           dest = "lib/net_support/archive/#{school.downcase}" 
           puts `svn move #{src} #{dest}`          
           puts `rm -rf #{src}`
       end

       puts `svn ci -m 'archive some schools'`
    
    end
    task :gen do
      school = $argv[:n].first.to_s      
      $argv[:t] = [:t1]
      t = <<-eof

  ["Fall","/", "/"],
  ["Spring","/", "/"],
  ["Summer","/", "/"] 
  
eof
      if school !~ /_/ && school !~ /^[a-z]+$/
          name = school;
          school = school.gsub(/ /,'_') || school; 
      else
         if school !~ /_/ && school.size <= 4
            name = school.upcase
            
         else
            name = school.split("_").map {|p|
                if p.size <= 4
                  p.upcase
                else
                  p.capitalize
                end
            }.join(" ")            
         end   
      end      
      school = convert_name(school)
      Dir.mkdir("lib/net_support/#{school}") rescue p "already exists"
      file = "lib/net_support/#{school}/#{school}.rb"
      if File.exists?(file)
          raise unless confirm("the parse file already exists delete it?")
      end
      File.open(file,'w') do |out|
          class_name = (school + "_parser").split("_").map{|s| s.capitalize}.join("")
          out << <<-eof
Info = {
    :name=>"#{name}",
    :nid=>"16777",
    :city=>"",
    :region=>"",    
    :country=>"united states",
    :semesters=>[
#{t}
    ]
}          
class #{class_name} < CourseParser
    def start
      
    end
end
eof
      end
      if confirm("add to svn")
        puts `svn up`
        puts `svn add lib/net_support/#{school}`
        puts `svn ci -m 'generated skeleto for #{school}'`
      end
    end
    def get_names
      if $argv[:f]      
          require 'open-uri'
          names = open("lib/net_support/semesters_only.txt").read.split("\n").map{|n| 
              new_name = convert_name(n).gsub(/\r/,'')
              new_name = nil if new_name.size == 0
              new_name
          }.uniq.compact
          names.each { |n|           
            raise "#{n} doesn't exists" unless File.exists?("lib/net_support/#{n}/#{n}.rb")
          }          
      else
          names = [$argv[:n].first.to_s]
      end      
    end 
    def convert_name(name)
        name.gsub(/\s+/,' ').strip.gsub(/ /,'_').gsub(/[&.']/,'').downcase
    end
    def get_parser(name)
        require 'vendor/rails/activesupport/lib/active_support/core_ext/array.rb'      
        require 'vendor/rails/activesupport/lib/active_support/core_ext/string.rb'              
        require 'lib/net_support/parser'      
        require 'lib/rails_1.2_compatibilities.rb' rescue nil
        school =  convert_name(name)
        parser_file = File.exists?("lib/net_support/#{school}/#{school}.rb") ? "lib/net_support/#{school}/#{school}" :
                     "lib/net_support/archive/#{school}/#{school}.rb"
        require parser_file  
        parser_class = (school.camelcase + "Parser").constantize      
        parser_class.new
    
    end
    desc "updates the school part of the yaml file"
    task :update_yml do
      get_parser($argv[:n].first.to_s).update_seasons
    end
    desc "generates a school yaml file" 
    task :generate_yml do           
      $debug = true
      if $argv[:debug].to_s == "false"
        $debug=false
      elsif $argv[:debug].to_s == "subject"
        $sdebug=true
        $debug=false 
      end    
      get_names.each do |name|
        parser = get_parser(name)
        parser.start_parsing
        parser.finalize      
        if $argv[:svn].nil? || $argv[:svn].to_s != "false"
            puts `svn up`
            puts `svn add #{parser.result_file}`
        end
      end
      if $argv[:svn].nil? || $argv[:svn].to_s != "false"
         puts `svn commit -m 'storing data'`      
      
      end           
    end    
    task :delete=>:environment do
      NetConfig.new($argv[:n].first.to_s).delete
    end
    task :testmail=>:environment do 
        Notifier::deliver_a_message("kim@oycas.com","asanieyan@oycas.com","hey","hey")
    end
    task :send =>:environment do
        config = NetConfig.new($argv[:n].first.to_s,:production)
        testfile = config.dir + "/" + config.name + ".html"
        f = ""
        from  = $argv[:f].first.to_s rescue prompt("enter your name:")
        File.open(testfile,"r"){|out| f = out.read}
        size = f.size / 1024
        from = from + "@oycas.com"
        puts "File Size : #{size} KB"
        puts "From: #{from}" 
        puts "Sending File to Kim..."
        Notifier::deliver_a_message("kim@oycas.com",from,"#{config.model.name} Test Result",f)
    end
    task :update_test=>:environment do
        require 'hpricot'
        require 'open-uri'
        env = $argv[:env].first rescue :production
        config = NetConfig.new($argv[:n].first.to_s,env) 
        raise "Can't be done in production environment" unless ENV['RAILS_ENV'] == "development" || config.get_server_ip == "10.10.10.103" || $argv[:force].to_s == "true"       
        config.support unless config.model
        doc = Hpricot(open(config.dir + "/" + config.name + ".html"))
        doc.at("div#test_header").inner_html = Hpricot(config.test_header).at("div#test_header").inner_html
        testfile = config.dir + "/" + config.name + ".html"
        File.open(testfile,'w') do |out|
            out <<  doc.to_html            
        end
        puts `svn up`
        puts `svn add #{testfile}`
        puts `svn commit #{config.dir} -m 'storing data for #{config.name}'`
        Rake::Task["net:send"].invoke        
    
    end
    task :test=>:environment do
        env = $argv[:env].first rescue :production        
        config = NetConfig.new($argv[:n].first.to_s,env)        
        raise "Can't be done in production environment" unless ENV['RAILS_ENV'] == "development" || config.get_server_ip == "10.10.10.103" || $argv[:force].to_s == "true"               
        if config.model
            raise unless confirm("continue deleting everything")
            [School,Season,Course, Semester, Season, Subject].each do |klass|
              klass.delete_all
            end
        end

        config.support    
        config.add_courses_to_school        
        text = [config.test_header]
        
        c = config.model.courses.size
        s1= config.model.subjects.size
        s2= config.model.courses.find(:all,:group=>"subject_id").size                  

        if s1-s2 != 0
          text << "<h3> NOTICE: </h3>"
          text << "#{s1-s2} subjects doesn't have any courses"          
          config.model.subjects.find(:all,:conditions=>"NOT EXISTS (SELECT NULL FROM courses WHERE subject_id = subjects.id)").each do |s|
            text << "<strong>" + s.name + "</strong> doesn't have any courses."
          end
          text << "<br/><br/>"
          
        else
           text << "there are total of #{s1} subjects with #{c} courses"           
        end
        f = ""
        f << "<div style='padding:20px'>"
        f << text.join("<br>")
        config.model.subjects.each do |subject|
            f << "<div> #{subject.name} </div>"
            f << "<div>"
            f << "<select size=10>"            
            subject.courses.each  do |c|
              f << "<option> #{c.full_title} </option>"
            end
            f << "</select>" 
            f << "</div>"
            f << "<hr>"
        end
        f << "</div>"        
        testfile = config.dir + "/" + config.name + ".html"
        File.open(testfile,'w') do |out|
            out << f            
        end
        puts `svn up`
        puts `svn add #{testfile}`
        puts `svn commit #{config.dir} -m 'storing data for #{config.name}'`
        Rake::Task["net:send"].invoke
    end
    task :support=>:environment do 
        env = $argv[:env].first rescue begin
          ENV['RAILS_ENV'].to_sym
        end
        get_names.each do |n|
          config = NetConfig.new(n,env)
          begin
            config.support 
          rescue Exception=>e
            puts e.message
            next
          end
          config.add_courses_to_school unless $argv[:courses].to_s == "false"
          update_calendar(config.model)
          if config.model.courses.size > 0
              config.model.update_attribute(:loaded,true) 
          end          
        end        
    end  
    def update_calendar(school)
          puts "\nsemester tree for #{school.name}"
          school.outline_seasons(true)
          puts "\n"
          puts "\ncurrent semesters for #{school.name}\n"
          school.semesters.find(:all,:order=>"start_date ASC").each do |sem|
              puts "#{sem.name}: #{sem.period}"
          end
          if confirm "update calendar"
            puts "\n"
            school.seasons.first.generate_calendar_year(Time.now.utc,true)
            school.semesters.find(:all,:order=>"start_date ASC").each do |sem|
                puts "#{sem.name}: #{sem.period}"
            end
            puts "\n"
          end         
    end
    task :update_calendar=>:environment do 
      if $argv[:n]
        n = $argv[:n].first.to_s
        schools = [NetConfig.new(n).model]
      else
        schools = School.find(:all)
      end
      schools.each do |school|
          update_calendar(school)
      end        
    end
    task :edit_seasons=>:environment do 
        env = $argv[:env].first rescue begin
          ENV['RAILS_ENV'].to_sym
        end
        n = $argv[:n].first.to_s
        NetConfig.new(n,env).edit_seasons
    end        
    task :add_seasons=>:environment do 
        env = $argv[:env].first rescue begin
          ENV['RAILS_ENV'].to_sym
        end
        n = $argv[:n].first.to_s
        NetConfig.new(n,env).add_new_seasons
    end        
    task :update_courses=>:environment do 
        env = $argv[:env].first rescue begin
          ENV['RAILS_ENV'].to_sym
        end
        n = $argv[:n].first.to_s
        force = $argv[:force].first.to_s == "true" rescue false
        NetConfig.new(n,env).add_courses_to_school(force)    
    end
end


class NetConfig
    require 'yaml'
    require 'lib/rake_util.rb'
    include Kernel::Confirmation    
    def initialize school_name,environment = :development  
   
      school_name.downcase!.gsub!(/ /,'_') rescue nil
      @name = school_name
      
      @environment = environment
      require 'semester.rb'
      begin
          @dir = "lib/net_support/#{school_name}"
          @config = YAML::load_file("lib/net_support/#{school_name}/#{school_name}.yml") 
      rescue Exception=>e
          puts e.message
          puts "trying the archive folder"
          @config = YAML::load_file("lib/net_support/archive/#{school_name}/#{school_name}.yml")
          @dir = "lib/net_support/archive/#{school_name}"
      end
    end
    def dir
      @dir
    end 
    def name
      @name
    end
    def model 
        (School.find(@config[:info][:nid].to_i) rescue nil)
    end
    def delete
        #@model.destroy
    end 
    def get_server_ip
        ip = `ifconfig`.slice(/\d+\.\d+\.\d+\.\d+/)
        ip = `ipconfig`.slice(/\d+\.\d+\.\d+\.\d+/) unless ip
        return ip
    end
    def edit_seasons        
        while true do
          model.outline_seasons
          season_name = prompt("Enter the season name")          
          node = model.seasons.find_by_name(season_name)
          next unless node          
          puts node.period
          begin
            respons = prompt("Enter name,start-end or skip the name if the name is the same").split(",") 
            if respons.size == 1
              name = node.name
            else
              name = respons.shift
            end
            s,e = respons.shift.split("-") rescue next
            old_start = node.calendar_year_start
            node.name = name
            node['start_str'] = s
            node['end_str']   = e   
            #old_start = old_start < calendar_year_start ? old_start : calendar_year_start            
            if confirm("save period as " + node.period)
                begin
                  node.save 
                  model.semesters.find(:all,:conditions=>["start_date >= ? ",old_start]).each do |sem|
                      if sem.season_id == node.id
                         puts "changing semester #{sem.name}"
                         puts "#{sem.period}"
                         node.set_base_year(sem.start_date)
                         sem.start_date = node.start_date
                         sem.end_date = node.end_date
                         sem.save
                         puts "#{sem.period}"
                      end
                  end                
                rescue Exception=>e
                  puts e.message
                end
            end
          rescue
            next
          end 
        end
    end
    def update_calendar_year
        model.seasons.first.generate_calendar_year(Time.now.utc,true)
    end
    def add_new_seasons
        while true do
          model.outline_seasons         
          node = model.seasons.root
          next unless node
          s_name,date_str = prompt("Enter the season name,start_date-end_date ").split(",") rescue next         
          s,e = date_str.split("-") rescue next
          season = Season.new(:name=>s_name,:school_id=>model.id,:start_str=>s,:end_str=>e)          
          if confirm("save season #{season.name}")            
            season.save
            node.add_child(season)
            begin
              season.before_update
              model.semesters.find(:all,:conditions=>["start_date >= ? ",node.calendar_year_start]).each do |sem|                              
                sems = season.root.generate_calendar_year(sem.start_date,true)
                unless sems.empty?
                  puts sems.map{|s| "add new semsester #{s.name} #{s.period}" }.join("\n")
                end
              end
              raise unless confirm("keep this season?")
              #need to recalculate the calendar year              
            rescue Exception=>e
              season.destroy
            end
          end
        end
    end
    def test_header
        text = []
        text << "<div id='test_header'>"
        text << "<div id='school_info'>"
        text << "<strong>School Info</strong>"
        text << "Name : " + model.name
        text << "Nid: " + model.id.to_s
        text << model.city + ", " +  model.region
        text << model.country
        text << "</div>"
        text << "<div id='semester_info'>"
        text << "<strong> Semester Info </strong>"
        text << model.outline_seasons(true).join("<br>")
        text << "</div>"
        text << "</div>" 
        return text.join("<br>")
    end
    def set_semesters
         semesters = @config[:info][:semesters]
         hashed_seasons = {}      
         default_paths = []         
         root = nil
         if @model.seasons.empty?         
           semesters.each_with_index do |s,i|
                s_name,s_date,e_date = s                 
                attr = {:name=>s_name}
                attr[:start_str] = s_date
                attr[:end_str] = e_date
                season = Season.new                
                season[:school_id] = @model.id  
                season.attributes = attr                                
                season.save 
                if i == 0 
                    root = season
                else
                  default_paths << [root.name,season.name]
                end                  
                hashed_seasons[season.name] = season                
            end
            paths = default_paths || @config[:info][:paths]
            paths.each do |path|
                path.each_with_index do |season_name,i|
                    season = hashed_seasons[season_name.gsub(/\s+/,' ').strip]
                    next_season_key = path[i+1] 
                    if next_season_key
                      next_season = hashed_seasons[next_season_key]                      
                      if next_season.nil?
                          puts next_season_key
                      end
                      season.add_child(next_season)                                            
                    end
                end
            end
            model.outline_seasons(true)
#            if confirm("delete school")
#               Season.delete_all("school_id = #{model.id}")
#               name = model.name
#               model.destroy
#               fail "#{name} deleted from db"
#            end
        else
          model.outline_seasons(true)
        end        
        
    end
    def support
      #raise "#{name} already supported" if model          
      config = {}.update(@config[:info])
      semesters = config.delete(:semesters)
      config.delete(:paths)
      nid = config.delete(:nid)  
      ip = get_server_ip
      sem_str = semesters.map{|s| "   " + s.join(" - ")}.join("\n")
      q = <<-eof
supporing '#{config[:name]}' with 
ip      : #{ip}
nid     : #{nid}
city    : #{config[:city]}
region  : #{config[:region]}
country : #{config[:country]}
subjects : #{@config[:courses].size} 
semesters : \n#{sem_str}                                                 
      eof
      fail "Opertaion Abort" unless confirm(q)    
      begin  
        @model = School.new(config)        
        @model['id'] = nid
        @model['sem_loaded'] = true
        @model.save           
      rescue Exception=>e                             
        @model.destroy if @model 
      end
      set_semesters
    end        
    def add_courses_to_school(force=false)
       #converts a hash of format     
       require 'course.rb'
       courses = @environment == :development ? @config[:courses][0..0] : @config[:courses]
       smodel = self.model
       puts $argv
       puts force
       courses.each do |subject|                     
           _subject = Subject.find_by_school_id_and_code smodel.id,subject[:code]
           if !_subject
               _subject = Subject.create :status=>:approved,:school_id=>smodel.id, :code=>subject[:code], :name=>subject[:name]                   
                puts 'creating subject: ' + _subject.code + " " + _subject.name               
           elsif _subject and (_subject.status != :approved or force)
                _subject.status = :approved
                _subject.name = subject[:name]
                _subject.save
                puts _subject.code + " " + _subject.name  + " updated"
           else     
                puts _subject.code + " " + _subject.name  + " already exists"
           end            
           subject[:courses].each do |course|               
               _course = Course.find_by_school_id_and_subject_id_and_number(smodel.id,_subject.id,course[:number])
               if !_course                  
                  begin
                  _course = Course.create :status=>:approved,:subject_code=>course[:subject],:number=>course[:number],:description=>course[:description],:name=>course[:name],
                                             :credit=>(course[:credit] || "").to_f, :school_id=>smodel.id,:subject_id=>_subject.id 
                  puts 'creating course: ' + _course.full_title                           
                 rescue Exception=>e                    
                    puts e.backtrace.join("\n")
                    puts e.message                    
                    unless @always_yes
                      raise e unless confirm("continue",{:always_yes=>true})                 
                    end
                 end
               elsif _course  and (_course.status != :approved or force)
                  _course.credit = course[:credit]
                  _course.status = :approved
                  _course.description = course[:description]
                  _course.name = course[:name]
                  _course.save
                  puts _course.full_title  + " updated."
               else
                  puts _course.full_title  + " already exists."
               end                                       
           end
       end            
    end
end
