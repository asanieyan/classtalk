module UploadedFileHandler
  def max_allowable_size
      nil
  end
  def extract_extn filename
        File.extname(filename).sub('.','').downcase 
  end
  def truncate_files(tmpfiles,options={},&block)
      filter = options[:filter_in] || options[:filter_out]
      maxsize = options.delete(:max_size) || max_allowable_size
      if filter 
        filter.map!{|f| f.downcase}
        filter_in  = options.delete(:filter_in) ? true : false
        
      end
      tmp =  tmpfiles.map{|t| (t == nil || t.size == 0) ? nil : t}.compact
      total_size = 0;
      tmp = tmp.select{|t| 
          ret_val = true
          if (filter) 
              ret_val = filter_in ? filter.include?(extract_extn(t.original_filename)) : !filter.include?(extract_extn(t.original_filename))
          end            
          ret_val = t.size <= maxsize if maxsize
          if ret_val
              total_size += t.size
          end
          ret_val
      }
      tmp.instance_eval <<-eof
          def total_size
              #{total_size}
          end
      eof
      if block_given?   
         tmp.each(&block)  
      else
        return tmp 
      end

  end
end
class Privacy
    attr_accessor :db_tag,:select_name,:human_title,:openness
    def initialize db_tag,select_name,openness,human_title,document
        @db_tag = db_tag
        @select_name = select_name
        @human_title = human_title
        @document = document
        @openness = openness
    end
    def human_title
        if @document.anonymous
            "This document is anonymous and #{@human_title} it."
        else
            @human_title + " this document."
        end
    end

end
class Document < ActiveRecord::Base   
   acts_as_reportable "Violates copyright", "Nudity or pornography", "Obscene", "Attacks individual or group",:owner=>"user",
                                :title=>'Report Document #{title}'
                                
   MaxSizePerUpload = 20
   has_many :comments, :as => :commentable

   def url   
       "/library/main?uid=#{self.user_id}&d=#{self.id}"
   end
   def self.of_course_sql(course,logged_in_user,query=true)
    query ||= true
    <<-eof
         #{query} AND course_id = #{course.id} AND
        (#{logged_in_user.is_admin?} OR user_id = #{logged_in_user.id} OR 
        (user_id IN (#{logged_in_user.friend_less ? -1 : logged_in_user.friends.to_s}) AND privacy NOT LIKE 'me' ) OR
        privacy IN ('ppl_in_net','all'))            
    eof
   end
   def self.of_person_sql(user,logged_in_user,query="true")
      scope = "user_id = #{user.id}"
      query ||= "true"
      privacy = ""
      if user.id == logged_in_user.id or logged_in_user.is_admin?
        privacy = "true"
      elsif logged_in_user.friends_with(user.id) 
        #all the user documents which are not intended to be seen only by the user and not anonymous
        privacy = "privacy NOT LIKE 'me'"
      else
        #TODO check if logged_in_user can search the viewed user (facebook profile privacy) if not then all the user documents
        #is considered anonymous
        #so the person can't and should not see the documents  
       if logged_in_user.supported_schools.include_schools?(user.schools) 
          privacy = "privacy IN ('all','ppl_in_net')"
       else
          privacy = "privacy = 'all'"
       end
       #same school                  
     end 
     "#{scope} AND #{query} AND #{privacy}"    
   end
   
   def can_report? user
     self.class.find(:first,:conditions=>self.class.of_person_sql(self.user,user,query="documents.id = #{self.id}"))     
   end
   
   require 'uri'
   include UploadedFileHandler
   acts_as_taggable
   strip_tags_and_truncate 'title',:remove_whitespace=>true
   strip_tags_and_truncate 'comment'
   has_many :files,:class_name=>"DocumentFile",:dependent=>:destroy do
        def vol            
            @vol ||= proxy_owner.files.inject(0) {|size,f| 
                  size += f.data.size
            }
        end
   end
   belongs_to :course
   belongs_to :school
   belongs_to :user
   belongs_to :semester
   
   def self.privacy_num(label)
      case label
          when 'me';0
          when 'friends';25         
          when 'ppl_in_net';300;
          when 'all';360;
          else raise "Invalid Label"
      end   
   end
   def before_create      
      self["privacy"] = "ppl_in_net"      
   end
   def viewed!
      self.increment!("num_views")
   end
   def privacy_objects    
      return Privacy.new("me","Only me",0,"Only you can view",self),
             Privacy.new("friends","Only my friends",1,"You and your friends can view",self),
#             Privacy.new("ppl_in_course","My Friends and People in  #{self.course.short_title}",2),
             Privacy.new("ppl_in_net","My Friends and People from #{self.school.name}",3,"Everybody at #{self.school.name} can view",self),
             Privacy.new("all","All People using ClassTalk",5,"All ClassTalk users have access to",self)
   end
   def privacy_title
      self.privacy.human_title
   end
   def privacy    
    privacy_objects.find{|p|  p.db_tag == self['privacy']}
   end  
   #get the document an allowable privacy object for the document according  to the db_tag
   #raise if it is an invalid db_tag   
   def get_privacy db_tag
      privacy_obj = privacy_objects.find{|p| p.db_tag == db_tag}
      raise unless privacy_obj
      return privacy_obj   
   end

   #set the document privacy according to the db_tag
   #raise if it is an invalid db_tag
   def set_privacy db_tag
      privacy_obj = privacy_objects.find{|p| p.db_tag == db_tag}
      raise unless privacy_obj
      self.update_attribute("privacy",privacy_obj.db_tag)
      return privacy_obj
   end
   def links= links
     self['links'] = (links.inject([]) do |link_array,link_uri|
        begin 
          parsed = URI::parse(link_uri)
          raise unless parsed.host and parsed.scheme
          link_array << link_uri          
        rescue           
        end        
        link_array 
     end).join(",")
    
   end
   def links
      (self['links'] || "").split(",") 
   end
   TitleError = "please enter a more descriptive title"
   def validate
      if title.size < 3
        errors.add 'title',Document::TitleError 
      end
   end
end
class DocumentFile < ActiveRecord::Base
    belongs_to :document
    def name;file_name;end;  
    def data
       data = nil
       File.open("user_data/docs/#{self.id}","r") do |f|
          data = f.read
       end
       return data
    end
    def before_destroy
       FileUtils.rm("user_data/docs/#{self.id}")
    end
    def << data
       FileUtils.mkdir_p("user_data/docs") unless File.exists?("user_data/docs")
       File.open("user_data/docs/#{self.id}","w") do |f|
          f << data
       end
    end

end
