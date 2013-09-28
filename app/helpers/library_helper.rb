module LibraryHelper
    
    def search_select_options prepend=nil        
        select_options = options_for_select([["All Documents","all0"]])
#        options += @user_supported_schools.map{|s| [s.name,"nid#{s.id}"]}            
        courses = []
        @user_supported_schools.each do |s|
            select_options << options_for_select([[s.name,"nid#{s.id}"]],params[:s])
            courses = Course.find(logged_in_user.classes.current_at(s).map(&:course_id).uniq).map{|c| [c.title_no_credit,"c#{c.id}"]}
            if !courses.empty?
               select_options << '<OPTGROUP LABEL="">' + options_for_select(courses,params[:s]) + '</OPTGROUP>'                 
            end
        end
        return select_options
        
    end
    def library_search_select_box prepend=nil
      select_tag("s",(prepend || "") + search_select_options ,:style=>"width:270px")
    end

end