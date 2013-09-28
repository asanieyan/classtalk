class LibraryController < PluginController
    include ClassTalk::CourseSelection
    skip_big_filters :only=>%w(privacy_changed)
    verify_xhr_requests :only=>["privacy_changed"]

    #GET Request
    #Parameters d - document id (required) 
    #           f - file id (optional) if not given then download all files in this document
    #Returns file data if the request is valid or nothing otherwise
    #school_aff_update is not needed 
    #logged_in_user requests to download a file f or all of file of the document 
    #if the logged_in_user passes the privcay settings of the document he can donwload the file          
    def get            
      begin
        doc = Document.find(params[:d])
        user,docs = ones_documents(doc.user_id,"documents.id = #{doc.id}")
        raise unless doc == docs.first
        doc.viewed!
        if params[:f]
          file = doc.files.find(params[:f])
          send_data(file.data,:filename=>file.name)
          return          
        elsif params[:l]
          link = doc.links[params[:l].to_i]
          redirect_to link
          return
        else
          require 'zip/zip'
          t = Tempfile.new(rand(100000).to_s + doc.title)
          Zip::ZipOutputStream::open(t.path) {
            |io|
            doc.files.each do |file|
              io.put_next_entry(file.name)
              io.write file.data
            end
          }
          File.open(t.path) do |f|
            send_data(f.read,:filename=>"#{doc.title}.zip")
          end

        end
      rescue Exception=>e
       # p e.message
        render_return
      end
    
    end
    #Queries the db to retrive documents based on the passed in parameters
    #Parameters: which - (friends,classmates,all) 
    #                     friends - show documents posted by friends
    #                     classmates - documents posted to my classes by whoever
    #                     all - union of friends and classmates
    def get_index_documents options={}
      options = {:which=>"friends"}.update(options)     
      which = options.delete(:which)
      classmates_documents = []
      friend_documents = []
      time = 10.days.ago     
      if which == "all" or which == "friends"
          friend_documents = Document.find(:all,:limit=>10,:conditions=>["user_id IN (#{logged_in_user.friends.to_s}) AND anonymous IS NULL AND privacy NOT LIKE 'me' AND created_on > ?",time])
      end
      if which == "all" or which == "classmates"
        classmates_documents = []        
        @user_supported_schools.each do |school|
          user_classes = logged_in_user.classes.at(school.curr_next_semesters).map(&:id).join(",")
          next if user_classes == "" or school.curr_next_semesters.empty?
          sql =  <<-eof 
              documents.user_id <> #{logged_in_user.id} AND
              privacy IN ('ppl_in_net','all') AND
              documents.created_on > ? AND
              EXISTS (
                SElECT * FROM klasses_users WHERE                
                klasses_users.klass_id IN (#{user_classes}) AND 
                klasses_users.semester_id IN (#{ids_of school.curr_next_semesters}) AND
                klasses_users.course_id = documents.course_id
              )
          eof
          classmates_documents += Document.find(:all,:limit=>10,:select=>"documents.*",
            :order=>"documents.created_on DESC",:conditions=>[sql,time])

        end        
      end
      return friend_documents, classmates_documents
      
    end
    def remove_comment
        doc = Document.find(params[:d]) rescue render_return
        comment = doc.comments.find(params[:id])  rescue render_return        
        render_return unless logged_in_user.id == doc.user_id or comment.user_id == logged_in_user.id or logged_in_user.is_admin?
        comment.destroy
        render_p 'doc_comments',:doc=>doc
    end
    #Submits a comment for a post 
    #Request comes directly from client
    def submit_comment
      begin
        doc = Document.find(params[:d]) rescue render_return
        #check to see if the logged_in_user can see this doc
        user,docs = ones_documents(doc.user_id,"documents.id = #{doc.id}")
        doc = docs.first 
        render_return unless doc
        comment = Comment.new(:body=>params[:comment].to_s[0..300],:user_id=>logged_in_user.id)
        raise_after :r_msg ,'error',:title=>comment.errors.on('body') unless comment.valid?  
        doc.comments << comment
        #if i am not replying to a comment
        if doc.user_id != logged_in_user.id
          Syndicate::story_for(logged_in_user,"doc_comment",:type=>"comment",:context=>doc,:locals=>{:comment=>comment})
        end

      rescue Exception=>e

      end
      redirect_to :back
    end
    private :get_index_documents
    #this is acutally an extension of the index to show the documents selected by the select box 
    #in the index template 
    #normally this should be part of the index since index and this are doing the same thing
    #whoever you can't submit a form using fbjs but you can use ajax to submit a form
    def show_docs 
      f_doc,c_doc = get_index_documents(:which=>params["poster"])
      doc = render_p_string 'documents',:documents=>(f_doc + c_doc).uniq,:showpic=>true

      size,summary = case params["poster"]
                    when "friends";[f_doc.size," posted by my friends."]
                    when "classmates";[c_doc.size," posted by people to my classes."]
                    else [(f_doc+c_doc).uniq.size,"."]
                end           
      render_json :fbml_docs=>doc,:summary=>"Displaying #{size} recent documents#{summary}"
    end    
    def index
        fb_redirect_to :action=>"main"
    end
    #GET Request 
    #Renders in Facebook Canvas
    #Get All the documents created by my friends that i can see
    #Get All the document created for one of my classes that i can see 
    def main                  
      conditions = []
      if params[:uid]         
        if params[:d]
            conditions <<  "Anonymous IS NULL" if (params[:uid].to_i != logged_in_user.id && !logged_in_user.is_admin?)
            conditions <<  "documents.id = #{params[:d].to_i}"
        elsif params[:uid].to_i != logged_in_user.id and !logged_in_user.is_admin?
            conditions << "Anonymous IS NULL"
        end           
        @user,@documents,@paginator = ones_documents(params[:uid],conditions)    
        return_after :fb_redirect_to,{:action=>"main",:uid=>@user.id} if params[:d] and @documents.empty?
        render_return :action=>"ones_documents"
      elsif params[:d] #returning an anonymous document that's why we are not using uid
        doc = Document.find(params[:d])  rescue render_return      
        @user,@documents,@paginator = ones_documents(doc.user_id,"documents.id = #{params[:d].to_i}")
        if @documents.empty?        
          return_after :fb_redirect_to,{:action=>"main"} 
        elsif (not @documents.first.anonymous) or @user == logged_in_user or logged_in_user.is_admin?
          return_after :fb_redirect_to,{:action=>"main",:uid=>@user.id,:d=>@documents.first.id} 
        end      
        render_return :action=>"ones_documents"
      elsif params[:c]
        @course,@documents,@paginator = course_documents(params[:c]) rescue render_return
        render_return :action=>"course_documents"
      end      
      @friend_documents,@classmates_documents = get_index_documents(:which=>"all")
      @all_docs = (@friend_documents + @classmates_documents).uniq
    end  
    #searches for documents in db
    #PARAMS 
    #           s   - the type of context t + the id of the context
    #           t   -  the type of context can 
    #               uid - search through the user documents with uid id
    #               c   - search through the course documents with c id 
    #                     note that the course must belong to one of my schools 
    #               nid - search through the school with nid id 
    #           q   - search parameter
    # if there is only q and no other search parameters then search the whole document db            
    # RETURN   - return a page headered with a uber search 

    def search
      context_id = params[:s].sub(/^([a-zA-Z]+)/,'') rescue render_return
      context = $1
      query = params[:q]  ? (params[:q].size > 2 ? "title LIKE '%#{params[:q]}%'" : "false") : 
                            (context == "all" ? "false" : "true")                            
      @search_context,@result_documents,@paginator = begin  case context
                                                          when "uid"
                                                            ones_documents(context_id,query)
                                                          when "c"
                                                            course_documents(context_id,query)
                                                          when "nid"
                                                            school_documents(context_id,query)
                                                          when "all"
                                                            classtalk_documents(query)
                                                          else
                                                            raise
                                                          end
                                                      rescue
                                                            [nil,[],nil]
                                                      end
    end
    def classtalk_documents (query="true")        
        paginator,documents = paginate :documents,:order=>"course_id ASC,created_on DESC",:conditions=><<-eof
             #{query} AND ( 
              #{logged_in_user.is_admin?} OR              
               user_id = #{logged_in_user.id} OR 
               (user_id IN (#{logged_in_user.friend_less ? -1 : logged_in_user.friends.to_s}) AND privacy NOT LIKE 'me' ) OR
               (school_id IN (#{@user_supported_schools.empty? ? -1 : @user_supported_schools.get_ids.join(",")}) AND privacy IN ('ppl_in_net','all')) OR
               privacy = 'all'              
            )            
        eof
        return nil,documents,paginator
    end
    #Search through a documents of the user;s schools
    def school_documents(nid,query="true")
        nid = nid.to_i
        school = School.find(nid)
        raise "Can't see someother schools notes, but you can search for it by title" unless @user_supported_schools.include_schools?(school)        
       
        paginator,documents = paginate :documents,:order=>"course_id ASC,created_on DESC",:conditions=><<-eof
             #{query} AND school_id = #{school.id} AND            
            (
              #{logged_in_user.is_admin?} OR user_id = #{logged_in_user.id} OR 
             (user_id IN (#{logged_in_user.friend_less ? -1 : logged_in_user.friends.to_s}) AND privacy NOT LIKE 'me' ) OR
              privacy IN ('ppl_in_net','all')
            )            
        eof
        return school,documents,paginator
    end
    #GET Request 
    #Parameters c - the course id of a course in my school
    #Get All the documents belonging to the course with id c
    # Steps raise an exception if the user is not allowed to see a course and render nothing
    #   1 - check if this course belongs to one of my schools if not raise
    #   2 - brings all the notes in course that satisfies the following conditions
    #       if note owner is me then don't care about privacy
    #       if note owner is friend then bring all the notes except the ones with privacy set to me
    #       if note owner is someone else then bring all the notes that privacy set ppl-in-net or ppl-in-classtalk
    #       if no notes found then return nothing
    def course_documents(c,query="true")
        c = c.to_i
        course = Course.find(c)       
        raise "Can't see someother schools course notes, but you can search for it by title" unless logged_in_user.is_admin? or @user_supported_schools.include_schools?(course.school)
        paginator,documents = paginate :documents,:conditions=>Document::of_course_sql(course,logged_in_user,query)
        return course,documents,paginator
    end
    #GET Request 
    #Parameters id - the id of the user whom we want to get all documents 
    #Get All the documents belonging to the user with uid = id
    # if we can't see the user name or picture because of the user facebook profile privacy then an exception is raise
    # and nothing is rendered
    def ones_documents(uid,conditions="true")       
       conditions = conditions.is_a?(String)? conditions : conditions.empty? ? "true" : conditions.join(" AND ")
       user = (uid == logged_in_user.id ? logged_in_user : User.find(uid.to_i))       
       paginate,documents = paginate(:documents,:conditions=>Document::of_person_sql(user,logged_in_user,conditions))
       return user,documents,paginate           
    end
    #GET Request
    #FBXHR? Request
    #removes a document from user 
    #doesn't need any type of school supports authentication only needs to make sure the document actually 
    #belongs to the user
    #so it still needs the a valid signiture
    #Parameters d - document id
    #           f - document file id optional if it is not there then destroy the whole document 
    def remove
        if params[:d] && params[:f]          
          (logged_in_user.is_admin? ? Document : logged_in_user.documents).find(params[:d]).files.find(params[:f]).destroy  rescue nil          
           render_return
        else
            doc = (logged_in_user.is_admin? ? Document : logged_in_user.documents).find(params[:d]) rescue render_return
            doc.destroy          
            @user,@documents,@paginator = ones_documents(doc.user_id)
           
            render :inline=><<-eof
              <%=render_p 'documents_page',
              :editable=>(@user == logged_in_user || logged_in_user.is_admin?),
              :search=>[fbml_name(@user.id,:linked=>false,:firstnameonly=>true,:possessive=>true),
                        {:s=>"uid#{@user.id}"}],
              :documents=>@documents,
              :showpic=>false,
              :paginator=>@paginator,
              :page_option=>{:uid=>@user.id},
              :summary=>"Displaying"%> 
            eof
            #can only delete a document using the xhr 
            return
        end
        
    end           
    private :ones_documents
    #XHR request
    #doesn't need any type of school supports authentication only needs to make sure the document actually 
    #belongs to the user
    #so it still needs the a valid signiture
    #Parameters - p - new privacy db_tag
    #             d - document id
    #             save - true : save this privacy the anon if any
    #Returns - Javascript Code to update the privacy image
    #                     and update the description
    def privacy_changed
      begin        
        document = logged_in_user.is_admin? ? Document.find(params[:d]) : logged_in_user.documents.find(params[:d])
        #must return a privacy object from which the openness value is used
        #to gauge the openness graph and update the explaination
        #to represent the privacy openness
        #if the privacy is invalid it will raise exception
        if params[:save] == "true"
            document.set_privacy(params[:p])
            unless  %w(me friends).include?(document.privacy.db_tag)
                document.anonymous = (params["anonymous"] == "true" ? :y : nil)           
            else
                document.anonymous = nil
            end
            document.save                      
            render :inline=>"<%=fbml_success 'Document Privacy Saved.'%>"
        else
          privacy = document.get_privacy(params[:p])
          anon = %w(me friends).include?(privacy.db_tag) ? false : true
          render_json :showAnon=>anon,:image_src=>"http://sfu.facebook.com/images/privacy/sparkline_#{privacy.openness}.jpg"
          return
        end
      rescue Exception=>e
#         p e.message
        render_return 
      end      
    end

    #GET Request from an iframe loaded by the create action
    #First step of creating a document by selection a course
    def step1
      
    end

    #POST Request step2
    #user must belong to the school before creating note
    #Request comes from both facebook and client
    #Request comes from facebook when showing the form
    #when submiting the form (with params[:commit]) then request comes from client
    #must render fbml
    #User can't post to a school that he is not a member of 
    #but can edit its documents
    def edit_document      
      if params[:c].to_i > 0
         @course = Course.find(params[:c]) rescue nil
         render_return unless @course.status == :approved
         #@course = nil if false #if not the course doesn't belong to the user
#         raise unless @user_supported_schools.map(&:id).include?(@course.school_id)
         if params[:d]
            @document = if logged_in_user.is_admin? 
                          Document.find(params[:d]) rescue nil
                        else                        
                          logged_in_user.documents.find(params[:d]) rescue nil
                        end
         end
         @document ||= Document.new(:user_id=>logged_in_user.id,:course_id=>@course.id,:school_id=>@course.school.id,:title=>flash[:title],:comment=>flash[:comment])
      end    
      #post comes directly to the classtalk not from facebook
      #but we must have
      if @course and params[:commit] == "yes"        
          begin
            @document.title = (params[:title] || "")
            @document.comment = (params[:comment] || "")
            raise_after_msg 'error',:title=>@document.errors.on('title') unless @document.valid? 
            saving_for_first_time = @document.new_record?
            raise_after_msg('error',
              %(You can't post documents to #{@course.school.name} library since you are not a member at #{@course.school.name})) if saving_for_first_time and not @user_supported_schools.include_schools?(@course.school)
            Document.transaction do               
              @document.links= params[:links].to_s
              @document.save
              #get all the uploaded files
              #check them for format and size
              #create document file objects and store them in the database
              #raise an error if any problem comes and don't create the document              
              
              files =  @document.truncate_files(params["files"] || [])                
              if files.total_size >= Document::MaxSizePerUpload.megabytes
                raise_after_msg 'error',:title=>"Maximum size per upload should be less than #{Document::MaxSizePerUpload} megabytes."
              end
              files.each do |file|
                f = DocumentFile.create(:file_name=>file.original_filename)
                f << file.read
                @document.files << f
              end
 
              #raise an error if the there are no file and links attach
              help = render_to_string(:inline=>"<%=link_to_help 'click here'%>")
              raise_after_msg 'error',"You must either attach some links or files to your document. If you have already attached some resources make sure they are in the right format. #{help} to see the supported formats.",
                    :title=>"You must attach resources" if @document.files.empty? and @document.links.empty?              
            end
          rescue Exception=>e
              flash[:title] = @document.title
              flash[:comment] = @document.comment
              redirect_to fb_url_for(:action=>'edit_document',:c=>@course.id,:d=>@document.id)
              return
          end
          #save succesfull
#          @document.tag_list = @document.title.split(" ").join(", ")          
#          @document.save
                 
          if saving_for_first_time            
            Syndicate::story_for(logged_in_user,'new_doc',:type=>Syndicate::PostDocument,
                                                          :locals=>{'doc_id'=>@document.id,:new_doc=>true},
                                                          :context=>@course)
            redirect_to  fb_url_for(:action=>'edit_document',:c=>@course.id,:d=>@document.id,:set_permission=>true)
          else
            Syndicate::story_for(logged_in_user,'new_doc',:type=>Syndicate::PostDocument,
                                                          :locals=>{'doc_id'=>@document.id,:new_doc=>false},
                                                          :context=>@course)
            r_msg 'success',"",:title=>"Document Info Saved."
            redirect_to  fb_url_for(:action=>'edit_document',:c=>@course.id,:d=>@document.id)
            return
          end
      end      
    end
    #does the same thing as edit_document
    #but has a differnt url name 
    #suitable url name for when creating documents rather then editing it
    def create
        edit_document
        render :action=>"edit_document"
    end
    #GET Request through an iframe loaded by the create in the permission tab
    #Parameters params[:c] course to which the document belongs to
    #           params[:d] document 
    #if they are not valid then render nothing
    def step3
        begin
         @document = logged_in_user.documents.find(params[:d])
        rescue
            render_return 
        end        
    end

    def browse 
        
    end
  private    
    def get_action_on_selected_course course,caller
      if caller == "documents_by_subject"

      elsif caller == "step1"

      end
    end
    def authorize_user      
      return true
    end
end 