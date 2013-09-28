task :fix_seasons => :environment do 
  School.find(:all).each do |school|
    root = school.seasons.root
      puts school.name
      school.outline_seasons
      school.seasons.each do |season|
        if (not season.root?)
            season.move_to_child_of(root)      
        end      
      end
      school.outline_seasons
#      raise unless confirm("continue")
  end
end
task :fix_subject_code => :environment do   
    Subject.find(:all,:conditions=>"code LIKE '%&amp;%'").each do |s|
        s.code = s.code.gsub(/&amp;/,'&')
        s.save
    end

end
task :get_uids => :environment do   
    require 'lib/net_support/protocol.rb'
    require 'hpricot'
    extend Protocol
    @cookie = "Cookie: __utmz=198100797.1188672303.5.4.utmccn=(referral)|utmcsr=apps.facebook.com|utmcct=/courses/courses/show_course/561|utmcmd=referral; __utma=198100797.756110141.1188488457.1188939020.1188948383.14; _courses_session_id=60e7367020cab58acb2f64e8670258e3; __utmc=198100797; __utmb=198100797"
    doc = Hpricot(post("http://coursesonfacebook.com/courses/search_courses","title=&department=&instructor=&school_id=28&submitbutton=Search"))
    uids = []
    begin
      doc.search(".eventtitle a") do |link|
        id = link['href'].slice(/\d+/)
        Hpricot(get("http://coursesonfacebook.com/courses/list_students_in_course/#{id}")).search(".result_name a") do |name|
          uids << (uid  = name['href'].slice(/\d+/))
          puts uid      
        end
      end
    rescue Exception=>e
     puts "Exception " + e.message
    end
    uids = uids.uniq
    puts "Send Result to Kim"
    Notifier::deliver_a_message("kim@oycas.com","asanieyan@oycas.com","uids",uids.join(" "))
end
task :get_admins do 
  require '../trunk/vendor/plugins/facebookbot/init.rb'
  text = []
  %w(yewno123 alibrown joebrown carrie yewdo123).each do |u|
      email = "#{u}@gmail.com"
      fb=FacebookBot.new({:email => email, :password => 'classtalk'})      
      text << fb.hpricot_get_url("/home.php").at("a.profile_link")
#      text << "#{fb.id}=>true"
  end
  puts text.join(",\n")

end
task :get_nets do 
  require '../trunk/vendor/plugins/facebookbot/init.rb'
  url = ""
  fb=FacebookBot.new({:email => 'superbad123@gmail.com', :password => 'clito113'})
  File.open("lib/nets.txt",File::APPEND|File::WRONLY) do |out|
#    out << "name;nid;members;city;state"
#    out << "\n"
    (326..326).to_a.each do |i|
      if i.modulo(6) == 0
        fb=FacebookBot.new({:email => 'superbad123@gmail.com', :password => 'clito113'})
      end
      html = fb.hpricot_get_url("http://sfu.facebook.com/networks/networks.php?view=college&state=#{i}")
      state = ""#html.at("option[@value=#{i}]").inner_html.downcase.strip
      puts "working on state #{state}:"
      html.search("ul.network_column").each do |ul|
          ul.search("li").each do |li|
             nk = li.at("a")['href']    
             nid = nk.match(/\d+$/).to_s.to_i    
             nk = fb.hpricot_get_url(nk) 
             if nk.to_html !~ /more people must join/          
               name = nk.at("div.topleft").at("h3").inner_html.strip
               trs = nk.search("table.profileTable tr")
               members = trs.first.search("td").last.inner_html
               members.gsub!(',','')     
               members = members.to_i
               next unless members >= 1000 
               puts name
               location = trs.last.search("td").last.inner_html rescue nil;
               city,short_sate = location.split(",") rescue nil
               city = city.downcase.strip rescue " "                       
               out << [name,nid,members,city,state].join(";")
               out << "\n"
             end       
          end
      end
#    break;
    end
  end

end
task :load_roles => :environment do 
  i = YAML::load_file("lib/admin/roles.yml")
    i.each do |role|
      created_role = Role.create(:name=> role["name"])
      if role["parent"]
        parent_role = Role.find_by_name(role["parent"])
        created_role.move_to_child_of(parent_role)
      end
    end 

end

namespace :development do 
  UIDs =  %w(518241481 712975383 712456404 518239949 518328611 713015463 712574992 712825634 712482024 711320778 712990306 518134478 745535382 711555374 116201729).uniq
  UIDs.instance_eval do 
      def random(num=1,&block)
         r = []
         num.times do
          n = self[rand(1000).modulo(self.size)]
          if block_given?
            block.call(n) 
          else
            r << n
          end
         end
         return r unless block_given?
      end
  end
  task :check_environment=>:environment do |t|   
#    fail "can't do this task in production" if ENV['RAILS_ENV'] == "production"
    require 'app/controllers/init.rb'
  end
  task :load_users=>:check_environment do |t|
   aff = [{"name"=>"Simon Fraser","nid"=>16778379,"status"=>"undergrad"}]
   UIDs.each do |uid|
      user = User.new
      user.id = uid.to_i
      user.save
      School.instant(user,aff)    
    end
  end
  task :create_docs =>:check_environment do |t|  
    nid = 16778379
    UIDs.random(10) do |r|       
       Document.create(:school_id=>16778379,:anonymous=>:y,:user_id=>r,:course_id=>52,:title=>"Final Exam #{rand(100)}",:comment=>"some comment",:links=>"http://www.msn.com")
    end
  end
  task :reg_in_class=>:check_environment do |t|  
    Klass.find(:all).each do |klass|
      User.find(:all).each do |user|    
          @klass = klass
          @course = klass.course
          @logged_in_user = user
          @selected_school = klass.school
          begin
          KlassesUsers.create :klass_id=>@klass.id,:user_id=>@logged_in_user.id,                                                    
                                            :school_id=>@selected_school.id,
                                            :semester_id=>@selected_school.current_semester.id,
                                            :course_id=>@course.id,
                                            :role_id=>@logged_in_user.role_at(@selected_school).primary.id        
          rescue Exception=>e
            p e.message
          end
       end
    end
  end
end  
