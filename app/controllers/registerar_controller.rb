class RegisterarController < PluginController
  include ClassTalk::CourseSelection
  
  

 
  #the label to be shown for your current courses
  CurrentCourseLabel = {Role::Student => "Current Courses I am taking",
                  Role::Instructor=>"Current Courses I am teaching"}             

  #when you are not asscociated with any class
  NoClass = {Role::Student => "You are not currenlty taking any classes at",
             Role::Instructor=>"You are not currenlty teaching any classes at"}
  
  #verb to take a class
  RegisterClass = {Role::Student => "register in this class",
                   Role::Instructor=>"teach this class"}  

  #what to show beside the class you are already a member of 
  InClass = {Role::Student => "you are taking this class",
                       Role::Instructor=>"you are teaching this class"}
  
  skip_big_filters :only=>%w(select_time update_classes)
  verify_post_requests :only=>%w(register_in_course)
  def index
    fb_redirect_to :action=>'register'
  end
  #renders an iframe that loads the list_subjects
  #the first step for registrations
  def register
      
  end
  #step 1 of registeration you select a school if you have more than 
  #no need for authentication
  #GET Request 
  #Parameters nid - id of the school to show the subjects for 
  def start_registration
  
  end
  #step 2 and 3 is provided by the CourseSelection module
  
  
  #step 4 of registration 
  #GET Request show the registration popup dialog
  #the course has been selected and the user is registering in the course
  #Parameter c course id  (required)
  def select_time    
    @course = Course.find(params[:c]) rescue render_return
    render_return unless logged_in_user.see_course?(@course)
    @semester = Semester.find(params[:sem]) rescue render_return
    
    render_p 'select_time' 
  end
  #updates the classes of a course in a semester
  #Param: sem semester id 
  #       c course id 
  def update_classes
    begin
      course = Course.find(params[:c])
      sem = Semester.find(params[:sem]) rescue Semester.find(:first,:conditions=>["id = ? ",params[:sem]])
      raise unless sem
      raise unless logged_in_user.join_course_at?(course.school) and 
                   course.school.valid_sem?(sem) 
      render_p 'classes_of_course','course'=>course,'semester'=>sem
    rescue Exception=>e
#      p e.message
#      puts e.backtrace.join("\n")
      render_return
    end
  end
  #step 5 of registration : register the user into the course or class
  #XHR Request 
  #Parameters - nid school id required
  #             c course id required
  #             k class id optional             
  #             remove [true] if a user wants to remove a class
  #             switch switch to class k
  #             day the day information passed in to create a new class
  #needs authentication
  #the combination of parameters determines the method functionality
  # c,k 
  #   if user is student means switch to class k
  #   if user is instructor means teach class k as well
  # c,k,remove 
  #   remove the class k from the user records
  # c,day create a new class and register user is in it   
  #some conditions a student can not be in more than one class of the same course, however teachers may be
#  def refresh_url
#      fbsession.fbml_refreshRefUrl(:url=>fb_url_for(:action=>"refresh_fbml"))
#      render :text=>"D"
#  end
  def refresh_fbml
     fbsession.profile_setFBML(:markup=>render_p_string('fb_profile/wide'))
     fb_redirect_to "http://www.facebook.com/profile.php?id=#{logged_in_user.id}"
  end
  def register_in_course
      begin                            
         @course = Course.find(params[:c])  
         @selected_school = @course.school
         @semester = Semester.find(params[:sem])        
         raise unless logged_in_user.see_course?(@course) && logged_in_user.join_course_at?(@selected_school) and 
                      @course.school.valid_sem?(@semester) and  logged_in_user.classes.created_at(@semester).size <= School::MaxNumberOfCreation
         #raise  "invalid course" if @course.school != @selected_school  #course doesn't belong to the school passed in as nid or one of the supported school of the user                  
         if params[:k]    #either want to switch to a class or drop the class           
           @klass = Klass.find(:first,:conditions=>["semester_id = #{@semester.id} AND school_id = #{@selected_school.id} AND course_id = #{@course.id} AND id = ?",params[:k]])           
           raise "Invalid class id " unless @klass 
           if params[:remove] #remove user
             #logger.debug  "remove the class " + @klass.inspect
             @removing = true
             @klass.users.delete(logged_in_user)
           else 
              #logger.debug  "reg in the class " + @klass.inspect
              #register user in class
              #if user is a student drop first drop him from all the classes of this course
              #it should only be one class since a student can only be registered in one class      
              #if the user is intructor, he can register as many classes as he wants however
              #it can register in the same class more than once 
             logged_in_user.classes_of(@course,@semester).each {|klass| 
                klass.users.delete(logged_in_user) if                  
                  logged_in_user.role_at(@selected_school).primary.is?(Role::Student) or 
                  klass == @klass or 
                  params[:switch] == true;
              } 
              raise if logged_in_user.classes.at(@selected_school,@semester).size >= School::MaxNumberOfCourses
              @registering = true
              KlassesUsers.create :klass_id=>@klass.id,:user_id=>@logged_in_user.id,                                                    
                                                :school_id=>@selected_school.id,
                                                :semester_id=>@semester.id,
                                                :course_id=>@course.id,
                                                :role_id=>@logged_in_user.role_at(@selected_school).primary.id
                              
           end
         elsif params[:day]  #want to register in a new class
           #create a new class for that day
            Klass.transaction do 
                 KlassSchedule.transaction do
                    if params[:day]
                        #create the klass first
                        raise "no day information is given to create new class" unless params[:day] #can't create a class without its day info can we
                        @klass = Klass.create(:course_id=>@course.id,
                                              :creator_id=>logged_in_user.id,
                                              :section=>params[:section],
                                              :status=>:approved,
                                              :school_id=>@selected_school.id,
                                              :semester_id=>@semester.id)    
                        @klass.set_time params[:day]
                    end
                    #makes the user member of a class
                    #the primary role of this user at this class determines its role
                    #in this class
                    #since this can only happen from registerar plugin then we don't to doulbe check the acceptable roles
                    raise if logged_in_user.classes.at(@selected_school,@semester).size >= School::MaxNumberOfCourses
                    @registering = true
                    KlassesUsers.create :klass_id=>@klass.id,:user_id=>@logged_in_user.id,                                                    
                                                      :school_id=>@selected_school.id,
                                                      :semester_id=>@semester.id,                                                 
                                                      :course_id=>@course.id,
                                                      :role_id=>@logged_in_user.role_at(@selected_school).primary.id
               end 
         end
       end                
      rescue Exception=>e   
         p e.message
         render_return
#        return
      end
      fbsession.profile_setFBML(:markup=>render_p_string('fb_profile/wide'))        
      verb = nil
      if @registering               
        Syndicate.story_for(logged_in_user,"joinleave",:type=>Syndicate::JoinOrLeaveClass,:locals=>{:klass=>@klass,:join=>true})        
        verb = render_to_string :inline=>" has joined the class network <%=link_to_class @klass,:full_name=>false%> at <%=@klass.school.name%>."
      elsif @removing
        Syndicate.story_for(logged_in_user,"joinleave",:type=>Syndicate::JoinOrLeaveClass,:locals=>{:klass=>@klass,:join=>false})        
        verb = render_to_string :inline=>"  has left the class network <%=link_to_class @klass,:full_name=>false%>."
      end
      if verb
        begin
          body = render_to_string :inline=>"<b> Join your real class network at <%=fb_link_to 'Classtalk',''%>.</b>"
          fbsession.feed_publishActionOfUser(:title=>verb,:body=>body) 
        rescue Exception
        
        end
      end
      
      #render the profile box
      if params[:profile]
          render_p 'profile/school_classes',:school=>@selected_school              
      elsif request.xhr?
          current = render_p_string('current_courses',{:schools => @user_supported_schools}).inspect    
          classes = render_p_string('classes_of_course',{:semester=>@semester,:course => @course}).inspect    
          render :inline=>"<%=render_p 'current_courses',{:schools => @user_supported_schools}%>splitfromhere<%=render_p('classes_of_course',{:semester=>@semester,:course => @course})%>"
      else
        #request is coming from the class so we go back to class
        fb_redirect_to :controller=>"classes",:action=>"main",:k=>@klass.id
      end
      
  end

 private
  def authorize_user
#    @selected_school = @user_supported_schools.find{|s| s.id == params[:nid].to_i}
#    @selected_school ||= @user_supported_schools.first   
##    p @logged_in_user.role_at(@selected_school)
#    (@logged_in_user.role_at(@selected_school).primary.is?(Role::Student,Role::Instructor) rescue false) if @logged_in_user
    return true
  end

end