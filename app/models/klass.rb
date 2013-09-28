class Klass < CachedModel #ActiveRecord::Base
     
    belongs_to :semester   
    belongs_to :course
    belongs_to :school
    has_many :klass_schedules
    has_many :instructor_invitations,:class_name=>"Invite"    
    
    strip_tags_and_truncate 'section'
    has_and_belongs_to_many :instructors,:class_name=>"User",:select=>"users.*",:conditions=>"role_id = 2"
    has_many :user_records,:class_name=>"KlassesUsers"
    has_and_belongs_to_many :users ,:select=>"users.*" do
        def with options
            #TODO must use the options as a key so whenever same option is passed we would have the cahced
            #result
            self.find(:all,options)
        end
    end

    has_many :comments, :as => :commentable, :order => "created_on DESC"
    
    has_many :topics, :as => :discussable, :class_name => 'Topic' do
      def unfiltered
        self.find :all
      end

      def by_userlist userlist=nil
        self.find :all, :conditions => ["user_id IN (?)", userlist]
      end

    end
    
#    has_many :klasses_users,:class_name=>"KlassesUsers" , :order=>"created_on DESC" do 
#        def last_one
#            @last_one ||= find(:first)
#        end
#    end             
    before_create :set_division
    
    strip_tags_and_truncate 'room'        
    
    def name            
        return course.subject_code+" "+course.number+"-D"+division.to_s
    end
    
    def closed        
        return self['status'].to_s == "rejected"
    end
    def role_of(user)
        @user_roles ||= {}                      
        @user_roles[user.id] ||= Role.find(:first,:joins=>"join klasses_users on klasses_users.role_id = roles.id",:conditions=>"klasses_users.klass_id = #{self.id} AND user_id = #{user.id}")
    end
    def is_editable?
        is_current? || is_coming_up?
    end
    #RETURN : whether the class belongs to the current semester or not 
    #used mostly in the class archive to determin some functinalities
    #like whether the viewing student can register in it or not
    def is_current?
      @is_current  ||=  self.semester.is_current?
    end
    def is_coming_up?
      @is_coming_up ||= self.school.next_semesters.include?((self.semester))
    end
    #validates the room value after being set 
    #if there are only white space in the room value it is set to nil
    def validate        
        self.room.strip!
        self.room = nil if  self.room !~ /\S/
    end 
    #set division of the class after being created 
    #basically it counts the number of clases of a certain in the current semester
    def set_division
        div = Klass.count(:conditions=>"semester_id = #{self.semester.id} AND course_id = #{self.course_id}") + 1
        self.division = div        
    end    
    def full_title
      self.name + " " + self.course.name
    end    
#    def notifiable_users action
#        case action
#              when "new_wall_msg"
#                  ["fbml_name(logged_in_user.id) + ' wrote a message on ' + link_to_class(@owner) + ' wall.'",
#                    self.users.find(:all,:joins=>"LEFT JOIN settings on users.id = user_id",:conditions=>"settings.name LIKE 'class_wall_ntfc' AND (settings.bool_val IS NULL OR settings.bool_val = 1)")]
#              else
#                [nil,[]]
#        end
#    end
    #used to return the name of this context instance to the wall or discussion
    #so this particular context instance can be human readable and comprehensible.
    def readable_context_name
      self.name
    end
    #used to return the url to return back to the context    
    def back_url
        "/classes/main?k=#{self.id}"
    end
    #used to return the proper controller name for example: since Klass isnt being used
    #as the Klass controller, and classes controller is used instead

#    def my_controller_name
#      "classes"
#    end
    
    #this method checks whether or not the user is registered in the klass
    def edit_class? user
      if user.member_of_class?(self)&& is_editable? then 
        return true;
      else
        return false;
      end
    end
    
    alias can_post? edit_class?
    
    #
    # called from Registerar Controller
    # basically it received a day keyed hash of 
    # day1=>"period1,period2",dayk=>"period1,...,periodl"
    # parse it and stores in the klass_schedules table
    def set_time days
      days.each do |day,times|
        periods = times.split(",")
        periods.each do |period|
            start_time,end_time = period.split("-")
            raise unless Time.parse(start_time) < Time.parse(end_time)                       
            #this will throw an exception if the day is invalid
            KlassSchedule.create :klass_id=>self.id,:start_time=>start_time,
                                 :end_time=>end_time,:day_of_week=>day
            end
        end 
    end

    def group_schedules
        time_sets  = Hash.new
        self.klass_schedules.each do |schedule| 
             key =  Time.parse(schedule.start_time).strftime("%I:%M %p").downcase.gsub(/^0/,"") + " to " + 
                    Time.parse(schedule.end_time).strftime("%I:%M %p").downcase.gsub(/^0/,"")
             value = schedule.day_of_week
             time_sets[key] = (time_sets[key] || []) + [value]
        end  
        return time_sets    
    
    end    
    def is_in_progress?
        
    end
    def formated_schedule(short=false)
       time_sets = group_schedules
       group = []
       time_sets.each do |time,days|
           group << (short ? days.map{|d| d.to_s[0..2]} : days).join(",").titlecase + " " + time
       end
       return group
    end
end
class KlassSchedule < ActiveRecord::Base
end
