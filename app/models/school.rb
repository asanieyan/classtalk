class School < CachedModel #ActiveRecord::Base
  has_many :klasses,:class_name=>'Klass',:dependent=>:destroy 
  has_many :semesters, :dependent=>:destroy 
  has_many :seasons
  has_many :courses,:dependent=>:destroy,:order=>"CAST(number AS SIGNED) ASC",:conditions=>"status LIKE 'approved' OR status LIKE 'pending'",:dependent=>:destroy 
  has_many :subjects , :order=>"code ASC" ,:conditions=>"status LIKE 'approved' OR status LIKE 'pending'",:dependent=>:destroy

  MaxNumberOfCourses = 5
  MaxNumberOfCreation = 8
  has_and_belongs_to_many :users   
  has_and_belongs_to_many :instructors,:class_name=>"User",:select=>"users.*",:conditions=>"role_id = 2"
  
  attr_accessor :status_changed
  def before_destroy            
      raise "you can't destroy a school where there is users in it" if self.users.size > 0

  end  
  def self.instant user,user_affiliated_schools
    supported_schools = []
    unsupported_schools = []   
    closed_schools = []
    user_affiliated_schools.each do |aff|
      school = self.find(aff["nid"]) rescue nil      
      if !school
        school = self.new(:name=>aff["name"])                
        school['id'] = aff["nid"]
        school.save
        school.set_default_seasons;
      end
      if !school.closed
         #school.update_attribute("name",aff["name"]) if school.name != aff["name"]
         if aff["status"] == "Alumnus/Alumna" && (aff["year"] >= Time.now.year && aff["year"] <= Time.now.year+2)
            aff["status"] = "Undergrad"
         end
         if !school.is_member?(user) #make user the member of the school based on their affiliation status in facebook
              school.set_new_member(user,aff["status"])              
         elsif (aff["status"].downcase != (school.record_of(user).fb_status || "").downcase)           
             #check their current affiliation with their previous affiliation 
             #store their old role with a new role in the notice table
             #TODO later we must do this
#               old_role = user.role_at(school)
#               new_role = Role::get(RoleMapper::fb_to_ct(aff["status"]))               
#               cond_hash = {              :user_id=>user.id,
#                                          :school_id=>school.id,
#                                          :resolved=>false,
#                           }
#               cond_sql  = cond_hash.to_a.map{|k,v| "#{k} = #{v}"}.join(" AND ")            
#               notice = StatusChangeNotice.find(:first,:conditions=>cond_sql)               
#               notice = StatusChangeNotice.new(cond_hash) unless notice
#               notice.attributes= {:old_role_id=>old_role.id,:new_role_id=>new_role.id}
#               notice.save
#               frozen_schools << school
                #TODO must check with role mapper to see if this transition is allowed or not
                #for now just update their primary role
                role = Role.get(RoleMapper.fb_to_ct(aff["status"]))
                school.record_of(user).update_attributes("role_id"=>(role.id rescue nil),"fb_status"=>aff["status"].downcase) 
                KlassesUsers.delete_all "user_id = #{user.id} AND school_id = #{school.id}"
               
                school.status_changed=true
         end
         supported_schools << school
      else
         closed_schools << school
      end
    end   
    [supported_schools,unsupported_schools,closed_schools]
  end
  def supported?; !new_record?;end
  
  def is_member?(user)          
      @members ||= {}
      @members[user.id] ||= self.users.find(user.id) rescue nil
      
  end
  def set_new_member user,facebook_status     
      return if is_member?(user) 
      role = Role.get(RoleMapper.fb_to_ct(facebook_status))
      #so during siginup the only person who has not a role is the staff
      #so they need to select their role 
      #so if the facebook status is not supported then no role is associated with that user 
      SchoolsUsers.create :user_id=>user.id,:school_id=>self.id,:role_id=>(role.id rescue nil),:account_status=>:activated,:updated_on=>Time.now.utc,:fb_status=>facebook_status.downcase rescue nil
     
  end
  def record_of(user)
      @user_records ||={}
      @user_records[user.id] ||=  SchoolsUsers.find(:first,:conditions=>"school_id = #{self.id} AND user_id = #{user.id}")

  end
  def valid_sem?(semester)            
      return curr_next_semesters.include?(semester)
  end
  def next_sem_reg?   
      !next_semesters.empty?
  end
  def curr_next_semesters     
    @c_n ||= next_semesters + current_semesters    
  end
  def set_default_seasons
        self.seasons << (root = Season.new(:name=>"Fall",:start_str=>"9/1",:end_str=>"12/25"))
        self.seasons << Season.new(:name=>"Spring",:start_str=>"1/1",:end_str=>"4/28")
        self.seasons << Season.new(:name=>"Summer",:start_str=>"5/1",:end_str=>"8/28")
        self.seasons.each do |season|
            if season != root
                root.add_child(season)
            end        
        end
        
  end
  def next_semesters    
    @next_semesters ||= Semester.find(:all,:conditions=>["school_id = #{self.id} AND ? < start_date AND start_date <= ? ",Time.now.utc.to_date,Time.now.utc + 25.days])
  end
  def current_semesters
    #running this for the first time    
    @current_semesters ||=                 
                    begin
                      if self.semesters.size == 0
                        seasons.first.generate_calendar_year(Time.now.utc) rescue set_default_seasons
                      end
                      if Time.now.utc >= seasons.first.calendar_year_end.ago(25.days)
                         seasons.first.generate_calendar_year(seasons.first.calendar_year_end.since(1.day)) rescue nil #already created
                      end
                      sems = Semester.find(:all,:conditions=>["school_id = #{self.id} AND ? BETWEEN start_date AND end_date",Time.now.utc.to_date])
                      #create next year calendar 20 days before end of this calendar
                    end                      
                                                      
  end
  def current_semester 
    raise "Don't Use this"
    @current_semester ||= (Semester.find(:first,
                            :conditions=>["school_id = #{self.id} AND ? >= start_date AND ? <= end_date",Time.now.utc.to_date,Time.now.utc.to_date]) ||
                              begin                                    
                                    season = self.seasons.current
                                    self.semesters << (sem = Semester.new({:season_id=>season.id,
                                                       :start_date=>season.start_date,
                                                       :end_date=>season.end_date}))                                    
                                    sem
                              end
                            )
                         
  end 
  def outline_seasons(include_year=false)
      leaves = self.seasons.reload.first.root.leaves
      paths = []
      paths_str = []
      leaves.each do |leaf|
          paths << leaf.self_and_ancestors
      end
      puts "\n"
      paths.each do |path|
         x = path.map{|s| s.name + " (#{s.period include_year})"}.join(" > ")
         paths_str << x
         puts x
      end  
      puts "\n"
      return paths_str
  end   


end
class RequestedSchool  < ActiveRecord::Base

end