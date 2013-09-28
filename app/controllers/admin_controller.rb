class AdminController < PluginController 
  def update_affiliations
    
  end
  def index
   
  end     
  def add_promoter
      if params[:promoter_id]
        pic = render_value("fbml_profile_pic(#{params[:promoter_id]})")
        name = render_value("fbml_name(#{params[:promoter_id]},:useyou=>false)")
        user_info = fbsession.users_getInfo(:uids=>params[:promoter_id],:fields=>"name").first
        code = ""
        user_info["name"].split(" ").each do |s|
            code << s.slice(/\w/)
        end
        new_code =  code + rand(99).to_s        
        while Promo.find(:first,:conditions=>"code LIKE '#{new_code}'")
            new_code = code + rand(99).to_s
        end
        render_json :fbml_promoter=>pic + "<br>" + name,:code=>new_code
        return
      elsif params[:del]
        Promo.delete_all(["user_id = ?",params[:del]])
        render_return
      elsif params[:commit]
          Promo.create(:user_id=>params[:user_id],:code=>params[:code]) rescue nil
          fb_redirect_to :action=>"index"
          return
      end        
  end
  def delete_req_school
      RequestedSchool.delete_all(["nid = ?",params[:nid]]) rescue nil
      render_return      
  end
  def get_season_dates(id)
      start_str = params[id.to_s + "_sm"] + "/" + params[id.to_s + "_sd"]
      end_str = params[id.to_s + "_em"] + "/" + params[id.to_s + "_ed"]
      return [start_str,end_str]
  end
  private :get_season_dates
  def edit_school
      @school = School.find(params[:nid]) rescue render_return
      if params[:post]
        error = nil
        begin
          @school.attributes = params[:info]
          @school.sem_loaded = true
          @school.save
          
          @new_season_added = @school.semesters.size == 0
          some_child = @school.seasons.first.root.children.first
          params[:seasons].each do |season_id,season_name|
              start_str,end_str = get_season_dates(season_id)
              if season_id =~ /^\d+/
                  season = @school.seasons.find(season_id.to_i)                  
                  season.name = season_name
                  season_old_start = season.start_date
                  season.start_str = start_str
                  season.end_str = end_str
                  season.save
                  #updating the semesters already created 
                  season.semesters.find(:all,:conditions=>["start_date >= ? ",season_old_start]).each do |sem| 
                      season.set_base_year(sem.start_date)
                      sem.start_date = season.start_date
                      sem.end_date = season.end_date                      
                      sem.save
                  end
              else
                 season = Season.new(:school_id=>@school.id,:name=>season_name,:start_str=>start_str,:end_str=>end_str)
                 if season.valid?                                       
                   @new_season_added = true
                   season.save
                   some_child.root.add_child(season)
                 end
              end              
          end          
          if @new_season_added 
              root = @school.seasons.first.root              
              @school.semesters.find(:all,:conditions=>["season_id = #{root.id} AND start_date >= ?",root.calendar_year_start]).map(&:start_date).each do |date|
                  root.generate_calendar_year(date,true)
              end
          end          
        rescue Exception=>e
          error = e.message          
        end
        render_p "school_info","school"=>@school
        return
      end
      render_p "edit_school"      
  end
  def sorted_seasons
      
  end
  def reset_fake_schools
      session['fake_schools'] = []
      render :nothing=>true
  end
  def get_school
      school = School.find(params[:s]) rescue render_return
      render_p 'school_info',{:school=>school}
  end
  def get_msg_links 

     render_p 'msg_links'
  end
  #PARAMETERS: uid (optional) - show the all the reports related to this user
  #            rid            - find all the reports of the reportable object of the report rid
  def reports
    if params[:uid]
       @user = User.find(params[:uid]) rescue render_return
    elsif params[:rid]
       @reportable = Report.find(params[:rid]).reportable rescue render_return        
    else 
      render_return
    end
  end
  def toggle_school
      School.find(params[:nid]).toggle!('closed') rescue nil 
      redirect_to :back    
  end
  def courses_exists?
  
  end
  def subject_exists?
     object = params[:type].constantize().find(params[:id])
     msg = ""     
     if object.is_a?(Subject) 
       subject = object
       subject.code = params[:v]     
       subject.before_save       
       s = Subject.find(:first,:conditions=>"id <> #{subject.id} AND code LIKE '#{subject.code}' AND school_id = #{subject.school_id}")              
       msg = render_to_string(:inline=>"<%=fbml_error 'this subject already exists as #{s.name}.'%>")   if s    
     elsif  object.is_a?(Course)
      course = object 
      course.number = params[:v]
      course.before_save
      c = Course.find(:first,:conditions=>"id <> #{course.id} AND subject_code LIKE '#{course.subject_code}' AND number LIKE '#{course.number}' AND school_id = #{course.school_id}")              
      msg = render_to_string(:inline=>"<%=fbml_error 'this course already exists as #{c.full_title}.'%>")   if c    
     end    
     render :text=>msg
       
  end
  def confirm_subject
     object = params[:t].to_s.constantize().find(params[:id]) rescue render_return;
     render_return unless object.is_a?(Subject) || object.is_a?(Course)   
     if params[:commit]
        if object.is_a?(Subject) 
          object['code'] = params[:scode]
          object['name'] = params[:sname]
          object.before_save
          s = Subject.find(:first,:conditions=>"id <> #{object.id} AND code LIKE '#{object.code}' AND school_id = #{object.school_id}")
          if !s and object.before_save
            object['status'] = :approved
            object.save
            object.courses.each do |course|
                course.update_attribute("subject_code",object.code)
            end
          else
            raise ""
          end
        elsif object.is_a?(Course)
          object['number'] = params[:cnum]
          object['name'] = params[:cname]
          object['credit'] = params[:cc]          
          object['description'] = params[:cdesc]
          course = object
          c = Course.find(:first,:conditions=>"id <> #{course.id} AND subject_id = '#{course.subject_id}' AND number LIKE '#{course.number}' AND school_id = #{course.school_id}") 
          if !c and course.before_save and course.status != :approved           
            course['status'] = :approved
            course.save
          else
            raise ""
          end                 
        end
        render_p 'added_courses'
     elsif params[:type] == "Reject"
        object.status = :rejected
        object.save
        if object.is_a?(Subject)
          courses = object.courses
          ids = ids_of(courses)
        else
          courses = [object]
          ids = [object.id]
        end
        KlassesUsers.delete_all("course_id IN (#{ids})")
        [Course.find(ids)].flatten.each do |course|
            course.update_attribute("status","rejected")
            course.klasses.each do |klass|
              klass.update_attribute("status","rejected")
            end
        end
        render_p 'added_courses'      
     else
        render_p 'confirm_subject',:object=>object
     end
  end  
  private
    def authorize_user
      return logged_in_user.is_admin?
    end 
end