Dir["lib/classtalk/libs/**/*.rb"].each do |rb_file|
  require rb_file
end
#makes it easier to add an array to another array as an element 
#use alot in the view methods that have blocks
class Array
    def random n=1
      if n == 1
        self[rand(self.length)]
      else
        duplicate = self.clone
        random_vals = []
        n.times do
           random_vals << duplicate.delete(rand(duplicate.length))
        end
        return random_vals
      end
    end
   def add *args
      push args
    end      
end
module ClassTalk
  module CourseSelection
      #Used in registration and library controller to allow a course selection for different purposes
      #to use this module you must include it in the controller
      #and use the partial course_selection to render a text box for course typeahead and the subject box
      def self.included(base)
        base.send :verify_xhr_requests, :only=>%w(find_a_subject find_a_course list_subjects list_courses describe_course suggest_course select_the_course)
        base.send :skip_big_filters, :only=>%w(find_a_subject find_a_course list_subjects list_courses suggest_course select_the_course describe_course)
      end

      def find_a_subject
          school = School.find(params[:nid]) rescue render_return           
          render_return unless logged_in_user.see_course?(school)          
          s = Subject.new(:code=>params[:s_code],:name=>params[:s_name])
          s.before_save
          subject = Subject.find(:first,:conditions=>["school_id = #{school.id} AND code LIKE ?", s.code])
          if subject
              render_json :index=>subject.id,:name=>subject['name'],:code=>subject['code']
          else
              render_json :name=>s['name'],:code=>s['code']
          end
      end
      def find_a_course
            school = School.find(params[:nid]) rescue render_return            
            render_return unless logged_in_user.see_course?(school)      
            subject = school.subjects.find(params[:s]) rescue render_return                        
            new_course = Course.new(:number=>params[:cnum].to_s,:name=>params[:cname].to_s)

            new_course.before_save
            course  = Course.find(:first,:conditions=>["school_id = #{school.id} AND subject_code LIKE '#{subject.code}' AND number LIKE ? ",new_course.number])                        
            ret = {}
            if course
              ret[:err] = case course.status
                              when :rejected   
                                  course.short_title + " has been added before was rejected by classtalk admins"
                              when :retiered
                                 course.short_title + " has been retiered by classtalk admins"                        
                              else
                                 course.short_title + " already exists"  
                          end
              new_course = course
           end
          ret[:num] = new_course.number
          ret[:name] = new_course.name
          render_json ret        
      end
      #submits the new course to the system
      #everthing must be checked
      #Parameters   s_code,s_name or s1   id of a selected subject or a new subject values 
      #             cname,cnum,cc,cdesc   course values to be added
      #Return must update the subject table             
      def submit_new_course
           @school = School.find(params[:nid]) rescue render_return
           render_return unless @user_supported_schools.include_schools?(@school)
           render_return unless logged_in_user.can_add_more_course(@school)
           #status = logged_in_user.is_admin? ? :approved : :pending           
           status = :pending
           if params[:s1].to_i > 0
              subject = @school.subjects.find(params[:s1]) rescue render_return
           else
              s = Subject.new(:code=>params[:s_code].to_s,:name=>params[:s_name].to_s)
              s.before_save
              subject = @school.subjects.find(:first,:conditions=>["code LIKE ?",s.code]) 
              unless subject                
                subject = Subject.new(:code=>s.code,:name=>s['name'],
                                      :creator_id=>logged_in_user.id,
                                      :status=>status)
                
                render_return unless subject.before_save
                @school.subjects << subject                      
              end
           end
           
           c = Course.new(:name=>params[:cname],:number=>params[:cnum])
           course  = @school.courses.find(:first,:conditions=>["subject_code LIKE '#{subject.code}' AND number LIKE ? ",c.number])
           render_return if course
           course = Course.new(:subject_id=>subject.id,
                               :creator_id=>logged_in_user.id,
                               :subject_code=>subject.code,
                               :number => c.number,
                               :name=> c.name,
                               :status=>status)

           render_return unless c.before_save
           @school.courses << course         
           render_p "course_display/list_subjects",{'caller'=>params[:caller],'subjects'=>@school.subjects.reload,'subject'=>subject}
           
      end
      #add a new course to a school
      #must be part of that school to be able to add the course
      #logged_in_user not have more than 7 pending course
      #logged_in_user not have more than 10 rejects
      def add_new_course
          @school = School.find(params[:nid]) rescue render_return
          render_return unless @user_supported_schools.include_schools?(@school)
          render_p 'course_display/add_new_course'
      end
      #XHR Request 
      #parameters nid - the school id
      #Suggest a list of courses from school with nid that matches the passed in parameters
      def suggest_course           
            school = School.find(params[:nid]) rescue render_return            
            render_return unless logged_in_user.see_course?(school)
            course_name = params[:cn] || ""
            render_return if course_name.size < 4
            
            course_number = []
            name_or_subject = []
            (values = course_name.split(" ")).each do |portion|            
                if portion =~ /\d+/
                    course_number << portion
                else #if portion.size >= 3
                    name_or_subject << portion                
               end
            end
            course_number = course_number.join('')
            name_or_subject = name_or_subject.join('%') 
            
            number_condition =   course_number.size > 0 ? "number LIKE '#{course_number}%'" : "true"
            results = Course.find(:all,:limit=>10,:order=>"CAST(number AS SIGNED) ASC",
                :conditions=><<-eof 
                    school_id = #{school.id} AND status IN ('approved','pending') 
                    AND (subject_code LIKE '%#{name_or_subject}%' OR name LIKE '%#{name_or_subject}%') AND #{number_condition}
                    eof
                    ).map{|c|                                           
                        name = c.subject_code.gsub(/(#{name_or_subject})/i,'{\1}') + " " + 
                               (course_number.size > 0 ? c.number.gsub(/(#{course_number})/i,'{\1}') :  c.number) + 
                               " - " + 
                               c.name.gsub(/(#{name_or_subject})/i,'{\1}')
                       {:name=>name,:id=>c.id}
                    }
          render :text=>results.to_json
      end
      #XHR Request
      #basically a course is selected through type ahead input box
      #then this method will show the subject box,course box and the selected course description     
      #TODO do we need authentication for this or not maybe a simple authentication
      #It is in a module because it is used in two different controller registarar and library
      #There is a bit of customization when showing the course 
      #Registerar shows the current classes of a course but the library doesn't need to    
      #parameters c - selected course id
      #Return renders the partial _list_subject which recursively will render all the partial to the course description
      def select_the_course
        course = Course.find(params[:c]) rescue nil
        render_return unless logged_in_user and course and logged_in_user.see_course?(course)
        render_p 'course_display/list_subjects',{'caller'=>params[:caller],'course'=>course}
      end    
      #shows the subjects of the school nid plus a typeahead text field for the courses of the 
      #school
      def list_subjects
         #TODO only list subjects from my own schools 
         #because then people can still it 
         school = School.find(params[:nid]) rescue render_return
         render_return if !logged_in_user.see_course?(school)
         render_p 'course_display/course_selection',{'caller'=>params[:caller],'school'=>school}
      end
      #shows the courses of a subject
      #used as step 2 of selecting a course
      #used in regisration and creating a document 
      #no need for authentication
      #XHR Request 
      #Parameters s - subject id 
      def list_courses        
        courses = Subject.find(params[:s]).courses rescue render_return
        render_return if courses.empty? or !logged_in_user.see_course?(courses.first)
        render_p 'course_display/list_courses',{'courses'=>courses,'caller'=>params[:caller]}
      end
      #step 3 of selecting a course shows the description of a selected course
      #used in registration and creating a document
      #if the user is already in the class 
      #if the user exceeds max number of allowed courses
      #XHR Request 
      #Parameters c - the  selected course
      def describe_course
        course = Course.find(params[:c]) rescue nil        
        render_return if !logged_in_user or !course  or !logged_in_user.see_course?(course)
        render_p 'course_display/describe_course',{'course'=>course,'caller'=>params[:caller]}
      end  
  end
  module RenderHelper
    def render_json json
        render :text=>json.to_json
    end 
    def render_p name,variables={}
        render :partial=>name,:locals=>variables
    end
    def render_value text
      render_to_string :inline=>"<%=#{text}%>"
    end
    def render_p_string name,variables={}
        render_to_string :partial=>name,:locals=>variables
    end
  end
  module TagHelpers      
      def lable_tag label,for_id,options={}
        content_tag(:label,label,options.update(:for=>for_id))
      end
      def table_tag options={}
        html = ""
        num_of_col_per_row = options.delete(:cols) || 2        
        yield(elements = []) 
        return html if elements.empty?
        options[:table] ||= {}
        options[:table][:cellspacing] ||= 0
        options[:table][:cellpadding] ||= 0        
        row = 0
        elements.in_groups_of(num_of_col_per_row) do |cols|                 
          row_content = ""
          row += 1
          cols.each_with_index do |col,i|
             col_content,col_options = col
             col_options ||= {}             
             col_options.update(options["col#{i+1}".to_sym] || {})
            row_content << content_tag(:td,col_content,col_options)           
          end          
          html << content_tag(:tr,row_content,options.delete("row#{row}".to_sym))         
          
        end   
        content_tag(:table,html,options.delete(:table))
      end    
  end
  module CodeHelper
      def ids_of(collection,attr=:id)
        collection.map(&attr).join(",")
      end
      def md5_of(string)
        require 'digest/md5';
        Digest::MD5.hexdigest(string)
      end
      def encrypt(value,key="yellowjacket")
         value = value.to_s
         require 'openssl'      
         c = OpenSSL::Cipher::Cipher.new( "des-ecb" )
         c.encrypt
         c.key = key        
         c.iv = c.random_iv         
         c.update(value) << c.final         
      end
      def decrypt(value,key="yellowjacket")
         value = value.to_s
         return value if value == ""
         require 'openssl'      
         c = OpenSSL::Cipher::Cipher.new("des-ecb" )
         c.decrypt
         c.key = key
         c.iv = c.random_iv 
         c.update(value) << c.final       
      end
  end
end  
module Facebook
  module FormHelper
    def fb_submit_tag(value = "Save changes", options = {})
      submit_tag value,options.update(:class=>"inputsubmit")
    end
    def fb_form_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
      form_id = options[:id] = (options[:id] || rand(10000))      
      concat(form_tag(fb_url_for(url_for_options),options,parameters_for_url) + capture(&block) +
            "</form>" ,
            block.binding)
    end
    def fb_button_to(name, options = {}, html_options = {})
        button_to(name,fb_url_for(options),html_options.update(:class=>"inputbutton"))
    end
    def fb_button_tag(name, html_options = {})
        content_tag("input","",html_options.update(:value=>name,:type=>"button",:class=>"inputbutton"))
    end
  end

  module JavascriptHelper
    
  end
  module MockAjaxHelper
    def fb_mock_ajax_options options={}
        updatable_element = options.delete(:update)
        form = options.delete(:form)
        remote_url = fb_url_for(options.delete(:url))
        options = {"clickrewriteid"=>updatable_element,"clickrewriteform"=>form,"clickrewriteurl"=>remote_url}            
    end
    def fb_link_to_remote name,options={}
        link_to name,"#",fb_mock_ajax_options(options)
    end
  end

end
class ActiveRecord::Base 
  include ClassTalk::FieldTextSanitizer  
  include ClassTalk::Reportable
  include ClassTalk::CodeHelper
end
class ActionController::Base
  include ClassTalk::RenderHelper
  include Facebook::UrlRewrite  
  include ClassTalk::CodeHelper
  #sometime it is easier to paginate an already made collection
  def paginate(collection_id, options={})
    if collection_id.is_a? Array
      per_page = options[:per_page] || 10   
      parameter = options[:parameter] || 'page'
      current_page = params[parameter]
      paginator = Paginator.new self,collection_id.size,per_page,current_page                                               
      return [paginator,collection_id[paginator.current_page.offset..paginator.current_page.offset+per_page-1]]                
    end
      super(collection_id,options)
  end
  #some helper methods derived from rails libs
  def self.verify_post_requests options
    verify options.update(:method=>:post,:render=>{:nothing=>true})
  end
  def self.verify_xhr_requests options    
    verify options.update(:xhr=>true,:render=>{:nothing=>true})
  end
  def self.verify_get_requests options
      verify options.update(:method=>:get,:render=>{:nothing=>true})
  end  

end
class ActionView::Base
  include Facebook::JavascriptHelper
  include Facebook::UrlHelper
  include Facebook::FBMLHelper
  include Facebook::MockFBML
  include Facebook::AssetHelper
  include Facebook::GuiComponents
  include Facebook::MockAjaxHelper
  include Facebook::FormHelper
  include ClassTalk::TagHelpers
  include ClassTalk::RenderHelper
  include ClassTalk::CodeHelper
  #must go to a better place
  def break_down(text,line_width=80,replacement="\n")
      if text =~ /\s/
          return text.gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip 
      end
      return text if text.size <= line_width        
      return text.gsub(/\n/, "\n\n").gsub(/(.{1,#{line_width}})/, "\\1#{replacement}").strip
  end    
  #since everything in the clastalk app is roled based
  #for different roles we need different labels so when rendering an action of 
  #plugin one can use get label to return the desired label for a given role
  #Parameters role - required
  #           constant name - this constant name must be wihtin the name space of controller
  def get_label role,const
      const = const.to_s.camelize 
      begin
        eval("#{controller.class}::#{const}")[role.name] || ""
      rescue
        ""
      end
    
  end
  def fbparams
     controller.fbparams
  end
  def fbsession 
    controller.fbsession
  end  
  def logged_in_user
    controller.send :logged_in_user
  end
  def in_facebook_canvas?
    return (fbparams["in_canvas"] != nil)
  end        
  def in_facebook_frame?
    return (fbparams["in_iframe"] != nil || fbparams["in_canvas"] != nil)
  end   
end
