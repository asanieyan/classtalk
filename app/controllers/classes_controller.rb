class ClassesController < PluginController

  #gets a uid or (name or email) of a teacher to be invited to teach this class
  #need to make sure the user is registered in this class before doing this
  #check first if this an invitation to a facebook user or an external person 
  # populate the invite table with 
  # inviter_id = logged_in_user.id
  # type = instructor 
  # class_id = this class id 
  # if external make sure the email and name are there and then send a email invitation 
  #     fb_user and app_user both nil
  # if facebook send a notification if you can must be tested
  #     fb_user = y
  #     invitee_id is the uid of the facebook user
  # if app user send a invite request if you can must be tested
  #     app_user = y
  #     invitee_id is the uid of the facebook user
  #parameters k     - klass id
  #           uid   - user id 
  #           name  - name of the teacher in case not a facebook user
  #           email - email of the teacher in case not a facebook user
#  def invite     
#      uid = params[:uid].to_i      
#      nid = @selected_class.school.id
#      render_return if uid == 0 or uid == logged_in_user.id      
#      user = User.find(params[:uid]) rescue begin
#           r = fbsession.fql_query(:query=>"SELECT uid FROM user WHERE #{nid} IN  affiliations.nid AND 'Faculty' IN affiliations.status AND  uid = #{uid}")
#           render_return if r.empty?
#           x = User.new;
#           x.id = r.first['uid']  
#           x 
#      end      
#      render_return if @selected_class.instructors.include?(user)
#      invite = Invite.new(:fb_user=>:y,:app_user=>(user.new_record? ? nil : :y),:invitee_id=>uid,:inviter_id=>logged_in_user.id,:invite_type=>"instructor",:klass_id=>@selected_class.id)
#      invite.save rescue nil;
#      subject = "You have been invited to teach #{@selected_class.name} for #{@selected_class.school.current_semester.name}"
#      url = render_to_string(:inline=>"<%=fb_message_url(#{uid},'#{subject}')%>")
#      redirect_to url
#  end
  #AJAX Request 
  #sends a fql to find 
#  def search           
#      nid = @selected_class.school.id
#      q = params[:q].to_s
#      if q == ""
#          render_p 'instructors_invite',:users=>@selected_class.school.instructors,:search_result=>false
#          return
#      end
#      results = fbsession.fql_query(:query=>"SELECT uid,name,affiliations.status FROM user WHERE #{nid} IN  affiliations.nid AND 'Faculty' IN affiliations.status AND  name = '#{q}'")
#      unless results.empty?
#        @query_results = results.inject([]) do |a,user|
#            u = User.find(user["uid"]) rescue User.new
#            u['id'] = user["uid"] if u.new_record?
#            a << u
#            a
#        end
#      else
#        @query_results = []
#      end
#      render_p 'instructors_invite',:users=>@query_results,:search_result=>true
##      render :action=>"add_instructor"
#  end
#  def add_instructor
#     #p fbsession.fql_query(:query=>"SELECT name,affiliations FROM user WHERE 16778379 IN affiliations.nid AND name = 'greg baker'")
#     #p fbsession.notifications_send(:to_ids=>"881645789",:notification=>(render_to_string :inline=>"has invited you to teach <%=fb_link_to @selected_class.name,{:action=>'main',:k=>@selected_class.id}%>"))
##    fbsession.notifications_sendRequest(:to_ids=>"116202455",   
##      :image=>"http://70.68.130.108:3000/images/post.gif", 
##      :type=>"teach a class",      
##      :content=>'Would you like to install my app?<fb:req-choice url="#{fb_url_for(:action=>"hey")}" label="Join" />',
##      :invite=>true
##      )
#     
#  end
  #Request Sent through ajax to change the room for the class
  #the logged_in_user must be registered in the class so 
  #the @registered flag must be on after successful change i will update renders the 
  #the new room text plus a link to change
 
  #browing the poeple of a class or all of your classes at once
  #parameters order - o     r(random),a(alphabetical) 
  #           sex   - sx    0(male),1(female)
  
  #           relationship_status r1    (0..5)
  #           meeting_sex   ii          [0..1]         
  #           meeting_for   if          [0..4]          
  FQLFields = {
      "sx" => "sex",
      "rl" => "relationship_status",
      "ii" => "meeting_sex",
      "pl" => "political",
      "if" => "meeting_for"
  }  
  ParamAttributeMap = {
      "sx" => ["'male'","'female'"],
      "rl" => ["'Single'","'In a Relationship'","'In an Open Relationship'","'Married'","'Engaged'",'"It\'s Complicated"'],
      "if" => ["'Friendship'","'Dating'","'A Relationship'","'Random Play'","'Whatever I can get'"],      
      "pl" => ["'Very Liberal'","'Liberal'","'Moderate'","'Conservative'","'Very Conservative'","'Apathetic'","'Libertarian'","'Other'"],
      "ii" => ["'Men'","'Woman'"],
  }
  
  def self.get_queries params    
      queries = {}
      ParamAttributeMap.each_key do |a|
         next unless params[a] and FQLFields[a]                  
         if params[a].is_a?(String)
           queries[FQLFields[a]] = [ParamAttributeMap[a][params[a].to_i]]
         else
           params[a].each do |i,v_i|
              v = ParamAttributeMap[a][v_i.to_i]              
              if  v 
                queries[FQLFields[a]] ||= []
                queries[FQLFields[a]] << v
              end
           end
         end
      end
      return "" if queries.empty?      
      "AND " + queries.inject([]) {|a,h|
          user_attr,values = h
          a.push("#{user_attr} IN (#{values.join(',')})")
          a
      }.join(" AND ")      
  end
  def browse               
      num_to_show = 10
      if @app_user 
        queries = self.class.get_queries(params) 
        @random_order = params["o"] == "a" ? false : true
        options = !@random_order ? {} : {:order=>"RAND()"}            
        users = @selected_class.users.with(options).map(&:id).join(',')        
        return_after :fb_redirect_to,{:action=>"main",:k=>@selected_class.id} if  users.empty?       
        queries = "SELECT uid,last_name FROM user WHERE uid IN (#{users}) #{queries}"
        @class_users = fbsession.fql_query(:query=>queries)
        @class_users = [] if @class_users.empty?
        if @random_order
          @class_users = @class_users[0..9] 
        else
          @class_users.sort!{|a,b| a['last_name']<=> b['last_name']}
          @paginator,@class_users = paginate(@class_users)
        end        
        @class_users = @class_users.inject([]) do |class_users,user|
              u = @selected_class.users.find(user['uid']) rescue next 
              class_users << u
              class_users
        end
      else
        @random_order = true
        @class_users = @selected_class.users.with({:limit=>10,:order=>"RAND()"})
        return_after :fb_redirect_to,{:action=>"main",:k=>@selected_class.id} if  @class_users.empty?        
      end
      if @random_order
        #create a fake paginator
        @paginator,@class_users = paginate(@class_users)
      end
      
  end
  
  def activities
     
  end

  def index
    fb_redirect_to :action=>'home'
  end

  def change_room
    render_return unless @registered and @selected_class.is_editable?
    room = params[:r].to_s
    room = nil if room.size == 0 or room.size > 10
    @selected_class.update_attribute('room',room)
    Syndicate::story_for(logged_in_user,'class_settings',:locals=>{:attr=>'room',:klass=>@selected_class},
                                                         :type=>Syndicate::ChangeClassElement,
                                                         :context=>@selected_class)

    render_p 'room_tag',{:klass=>@selected_class,:changable=>true}    
  end
  #GET Request
  #Shows all of the logged_in_user classes as tabbed view (whether teaching or taking)
  #this resembles the network page of facebook
  #and render the current class
  def main      
      if @app_user 
        @can_join = logged_in_user.join_course_at?(@selected_class.school) &&
                    (@selected_class.is_current? || @selected_class.is_coming_up?)                                                            
        @random_stat_topic = %w(sex political relationship_status)[rand(3)]
        random_class_uids = @selected_class.users.with(:order=>'RAND()').map(&:id).join(',')
        @class_random_users = fbsession.fql_query(:query=>"SELECT uid,#{@random_stat_topic} FROM user WHERE uid IN (#{random_class_uids})")
        #p fbsession.users_getInfo(:uids=>'116204126',:fields=>"interests")
        @friends_in_class = @selected_class.users.find(:all,:conditions=>"user_id IN (#{logged_in_user.friends.to_s})")
        if  @same_network
          @class_instructors = @selected_class.instructors #.select{|t| @class_random_users.include?({"uid"=>t.id}) }
          @random_docs = Document.find(:all,:conditions=>Document::of_course_sql(@selected_class.course,logged_in_user),:limit=>3,:order=>"updated_on DESC,RAND()")
        end
      else
        @class_random_users = @selected_class.users
        @friends_in_class = []
      end
  end 
  skip_big_filters :only=>'toggle_filters'
  def toggle_filters
       filter,off = params[:filter].shift.to_a
       session['browse_filters'] ||= {}
       if off == "true"
          session['browse_filters'][filter] = true
       else
          session['browse_filters'].delete(filter)
       end
       render_return
  end
  private
    def authenticate
      if !fbsession.is_valid? and (action_name == "main"  or   action_name == "browse" ) 
         @logged_in_user = User.new
         @logged_in_user.instance_eval do 
            def id
              -1;
            end
            def before_save
                raise
            end
         end 
      else
        super
      end
    end

    def choose_layout
        "canvas_layout.rhtml"
    end
    def authorize_user
      
      @app_user = fbsession.is_valid?            
      if params[:k]
        begin
          @selected_class = Klass.find(params[:k]) 
          @selected_semester = @selected_class.semester 
          @all_semesters = Semester.find(:all,:conditions=>"EXISTS (SELECT NULL from klasses_users WHERE user_id=#{logged_in_user.id} AND semesters.id = semester_id)",:order=>"school_id, start_date DESC") rescue []
          @same_network = @app_user && @user_supported_schools.include?(@selected_class.school)      
          @registered = @app_user && @same_network && logged_in_user.member_of_class?(@selected_class)
        rescue 
        
        end
      end
      if not @selected_class and @app_user
         @all_semesters = Semester.find(:all,:conditions=>"EXISTS (SELECT NULL from klasses_users WHERE user_id=#{logged_in_user.id} AND semesters.id = semester_id)",:order=>"school_id, start_date DESC") 
          return_after :fb_redirect_to,:controller=>"profile" if @all_semesters.empty?
          @selected_semester = @all_semesters.find{|s| s.id == params[:sem].to_i} if params[:sem].to_i > 0           
          @selected_semester ||= @all_semesters.first
          @selected_class = logged_in_user.classes.at(@selected_semester).first
          @same_network = @registered = true         
      end
      render_return unless @selected_class                              
      return true
    end  
end