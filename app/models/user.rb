class Promo < ActiveRecord::Base

end
class Setting < ActiveRecord::Base
    

end
class User < CachedModel #ActiveRecord::Base
  Testers = YAML::load_file('config/people.yml')['testers']
  Admins  = {
      116202455 => true, #arash
      698188239 => true,
      565620058 => true, #steven      
      699638379 => true,
      610184174 => true, #kim
      712143387 => true,
      602527981=>true, #fakes 2
      600894425=>true,
      601972184=>true,
      604599681=>true,
      602838151=>true      
  }  
  has_and_belongs_to_many :schools,:select=>"schools.*,schools_users.role_id,schools_users.account_status,schools_users.fb_status,schools_users.updated_on"
  
  has_many :created_courses,:class_name=>"Course",:foreign_key=>"creator_id" do
      def rejected 
          @rejected ||= self.find(:all,:conditions=>"status LIKE 'rejected'")
      end
      def pending
          @pending ||= self.find(:all,:conditions=>"status LIKE 'pending'")
      end  
  end
  has_many :created_subjects,:class_name=>"Course",:foreign_key=>"creator_id"  
  
  has_many :removed_objects,:foreign_key=>"creator_id"
  has_many :documents
  has_many :friend_invites ,:class_name=>"Invite",:foreign_key=>"inviter_id",:conditions=>"invite_type LIKE 'friend'"
  has_many :comments

  has_many :reports_made , :class_name=>"Report",:foreign_key=>"reporter_id",:order=>"resolved DESC"
  has_many :reports_got , :class_name=>"Report",:foreign_key=>"user_id",:order=>"resolved DESC"

  has_many :posts
  has_many :topics
  
  has_and_belongs_to_many :classes,:class_name=>"Klass" do     
    def created_at(semester,options={})
        @created_klasses ||= {}
        @created_klasses[semester.id] = nil if options[:reload] 
        @created_klasses[semester.id] ||=   self.find_by_sql("SELECT * FROM klasses WHERE creator_id = #{proxy_owner.id} AND semester_id = #{semester.id}")      
    end
    def at *semesters
        options = semesters.last.is_a?(Hash) ? {:reload=>false}.update(semesters.pop) : {:reload=>false}
        semesters = [semesters].flatten
        return [] if semesters.empty?
        key = semesters.map!(&:id).sort{|a,b| a <=> b}
        @klasses ||= {}
        @klasses[key] = nil if options[:reload]
        @klasses[key] ||= begin
             self.find(:all,:select=>"klasses.*",         
                  :conditions=>"klasses.semester_id IN (#{semesters.join(",")})")
        end
    end
    def current_at(schools,reload=false)        
        @current_klasses ||= {}     
        schools = [schools] unless schools.is_a?(Array)
        schools.inject([]) do |class_array,school|
          next unless school.supported?                        
          if (reload or @current_klasses[school.id].nil?) && !school.curr_next_semesters.empty?
            @current_klasses[school.id] = self.find(:all,:select=>"klasses.*",         
                  :conditions=>"klasses.semester_id IN (#{(school.curr_next_semesters).map(&:id).join(',')})")                  
          end
          class_array << @current_klasses[school.id] if @current_klasses[school.id]
          class_array.flatten  
        end
    end
  end 
  def classes_of(course,semester)    
     self.classes.at(semester).select{|klass| klass.course_id == course.id }
  end
  def member_of_class?(klass)
      !klass.users.find(self.id).nil? rescue false
  end
  def is_in_the?(c,semester=nil)
     semester = c.is_a?(Klass) ? c.semester : (semester || c.school.current_semester); 
     classes = self.classes.at(semester).select{|klass| c.is_a?(Course) ? klass.course.id == c.id : klass.id == c.id}
     return nil if classes.empty?
     classes
  end   
  #brings all the news feed relevant to this user somehow
  def feeds
    @feeds ||= begin
        f = self.friends.to_s
        k = supported_schools.map {|s| classes.at(s.curr_next_semesters)}.flatten
        docs = self.documents.map(&:id).join(",")
        c =  k.map(&:course_id).uniq.join(",")
        ks = k.map(&:id).join(",")
        sql = []
        sql << "user_id IN (#{f}) AND context_type IS NULL"          unless f.empty?
        sql << "context_type LIKE 'Klass' AND context_id IN (#{ks})" unless ks.empty?
        sql << "context_type LIKE 'Course' AND context_id IN (#{c})" unless c.empty?
        sql << "context_type LIKE 'Document' AND context_id IN (#{docs})" unless docs.empty?
        return [] if sql.empty?
        sql = "("  + sql.map{|q| "(#{q})"}.join(" OR ")  + ")"
        sql = "user_id <> #{self.id} AND " + sql
        feeds = Syndicate.find(:all,:conditions=>sql,:limit=>15,:order=>"created_on DESC")
        feeds
    end    
  end
  #checks whether a person can add a course 
  #the user is not able to add a course if 
  #if a person has x number of pending courses 
  #if a person has x number of rejected courses
  #if a user is admin it can add a course
  MaxPendingCourses = 10
  MaxRejectedCourses = 10
  def can_add_more_course(school,msg=nil)
      msg ||= ""
      if self.created_courses.pending.size > MaxPendingCourses   
        msg.replace("You have already added #{MaxPendingCourses} courses that are not approved yet. You must wait until they are approved before adding more courses.")
      elsif self.created_courses.rejected.size > MaxRejectedCourses 
        msg.replace("You have been rejected more than #{MaxRejectedCourses} times now. You can not add anymore courses for now.")      
      end      
      msg == ""
  end
  #since we don't store the relationship of facebook user
  #and we get a list of friends of hte logged_in_user
  #we just use the friends setter and getter in the application auth method to 
  #to set the relationship between users
  def friends=(uids)
    @friends = uids
    @friends.instance_eval do
        def to_s
            self.empty? ? "0" : self.join(",")
        end
    end
  end
  def friends_here
    @friends_here ||= self.class.find(:all,:conditions=>"users.id IN (#{friends.to_s})")
  end
  def friends 
    @friends || [0]
  end
  def friends_with(uid)
    friends.include?(uid.to_i)
  end
  def friend_less
    friends.empty?
  end
  #set the an instance variable user supported schools for the user
  #this is a subset of the user.schools
  #we don't use that because it return all school the user is associated with
  #in classtalk 
  def supported_schools= sup_schools
      @sup_schools = sup_schools
  end
  def supported_schools 
      @sup_schools || []
  end
  ###################################
  def is_admin?
      Admins[self.id] == true
  end  
  def is_tester?
    @is_tester ||= Testers.include?(self.id)
  end
  #Parameters: c - can be a course object or class object (must implement the function c.school)
  #Returns: Array of classes in which user belongs to in that course
  # for the students it should be one class
  # for the instructor it can be more than one class since they can teach more than one class
  # nil of the there is no class  
  #it is the responsibility of the user to make sure the returned value is what he was expecting
  def role_at school
     school.record_of(self).role rescue nil
  end
  def see_course?(course)
      if course.is_a?(School)
        school = course      
        status_checked = true      
      elsif course.is_a?(Subject) or course.is_a?(Course)
        school = course.school
        status_checked = [:approved,:pending].include?(course.status)
      else
        return false
      end
      self.schools.include?(school) && status_checked
  end
  def join_course_at?(school)
    @acceptance = {}
    @acceptance[school.id] ||= begin
        self.role_at(school).is?(Role::Student,Role::Instructor) rescue nil
    end    
  end
  has_many :change_notices,:class_name=>"StatusChangeNotice"
  def change_notices_at(school,onlyunresolved=true)
      cond = "school_id = #{school.id} AND user_id = #{self.id}"
      cond << "resolved = 0" if onlyunresolved
      StatusChangeNotice.find(:all,cond)
  end

  def exceed_max_reg_at school
    school.exceeds_max_reg self
  end
  def all_current_classes    
    self.classes.current_at(School.find(:first))
  end
  def after_create
    self.account_status = :activated
    save
  end
  def stamp_access!
    self.access_time = Time.now.utc
    self.save
  end
  has_many :settings  
 
  def notifications
      [
        ["Writes a new comment on my class wall","class_wall_ntfc"],      
        ["Starts a new discussion in my class","class_topic_ntfc"],      
        ["Posts a new document to class","class_doc_ntfc"]
      ]
  end
  def find_setting name,context
      context ||= self
      sql_condition =  "name LIKE '#{name}' AND context_type LIKE '#{context.class.to_s}' AND context_id = #{context.id}"
      self.settings.find(:first,:conditions=>sql_condition)
  end
  def get_setting name,fallback_value,context=nil
      setting = find_setting name,context
      setting = save_setting name,fallback_value,context if setting.nil?
      return setting
  end
  def save_setting name,value,context=nil
      setting = find_setting name,context
      options = {}
      unless setting
          context ||= self
          if context
            options[:context_type] = context.class.to_s
            options[:context_id] = context.id
          end
          options.update(:user_id=>self.id,:name=>name)      
          setting = Setting.new(options)
          options = {}
      end
      if value.is_a?(TrueClass) or value.is_a?(FalseClass)
          options[:bool_val] = value
      else
          options[:val] = value
      end 
      setting.attributes = options
      setting.save         
      return setting
  end  
  #takes a class instance as an argument
  #and attempts to activate that classes
  #can_post? method...
  def can_post? context_klass
    begin 
      context_klass.can_post?(self)
    rescue Exception => e
      #puts e
      return false
    end
  end
  
end