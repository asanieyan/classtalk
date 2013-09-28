#this must goes to a better place than this 
#load 'lib/classtalk/init.rb'
if ENV["RAILS_ENV"] == "development"
  Dir["app/models/*.rb"].each do |rb_file|
    load rb_file
  end 
end
module ClassTalk::AbstractRequestFBModifications
    def xhr?
     post? and ((parameters["xhr"] == "true") || super)
    end
end    
ActionController::CgiRequest.send :include,ClassTalk::AbstractRequestFBModifications
class ApplicationController < ActionController::Base   
  ip = `ifconfig`.slice(/\d+\.\d+\.\d+\.\d+/)
  ip = `ipconfig`.slice(/\d+\.\d+\.\d+\.\d+/) unless ip
  facebook_app_config = YAML::load_file('config/facebook.yml')[ip]
  API_KEY = facebook_app_config["application_api_key"]
  SECRET_KEY = facebook_app_config["application_secret_key"]
  FACEBOOK_APP_HOST =  facebook_app_config["facebook_application_host"]
  FACEBOOK_APP_URL = facebook_app_config["application_url"]
  APP_SERVER = facebook_app_config["application_server"]
  APP_ASSET_SERVER = facebook_app_config["application_asset_server"] || APP_SERVER
  APP_ID = "app" + facebook_app_config["application_id"].to_s
  FACEBOOK_APP_INSTALL_URL = "http://www.facebook.com/apps/application.php?api_key="+API_KEY  
  include RFacebook::RailsControllerExtensions    
  layout :choose_layout
  before_filter do |controller|
      if controller.action_name == "render_msg"
        controller.send :render_msg
        raise ReturnAfterRenderException
      end
  end
  
  before_filter :authenticate,:update_affiliations
  after_filter :prepare_send_off,:sign_forms,:insert_messages
    
  protected 

  #this is for development purpose only 
  #in the production it should always return fbsession.session_user_id
  #but in development can be used to login as different user 
  def get_session_uid    
    fbsession.session_user_id
  end
  def facebook_api_key
    API_KEY
  end 
  def facebook_api_secret
    SECRET_KEY
  end 
  def logged_in_user
      @logged_in_user ||= User.find(get_session_uid) rescue nil
  end
  def send_notification users,fbml
      return if users.nil? or users.empty?
      fbml = render_to_string :inline=>"<%=#{fbml}%>"
      puts fbml
      return fbsession.notifications_send(:to_ids=>users.map(&:id),:notification=>fbml)
  end
  #basically the authentication engine of classtalk it uses the Matt Pizzimenti RFaceboook session management
  #TODO must write our own his is kindda confusing but works for now 
  def authenticate  
    if !fbsession.is_valid?       
      logger.info '**********************************************'
      logger.info 'hello my friend you are not from here'
      logger.info "Current API KEY = #{API_KEY} ? Sent API Key = #{params['fb_sig_api_key']} : #{params['fb_sig_api_key'] == API_KEY}"
      if in_facebook_canvas?
#        fb_redirect_to FACEBOOK_APP_INSTALL_URL
        fb_redirect_to FACEBOOK_APP_INSTALL_URL
      else
         redirect_to FACEBOOK_APP_INSTALL_URL
      end
      return false
    end    
    #normally the request object checks wheter an incoming request has the session_key cookie 
    #if yes it tries to find the session with key if not it will make a new one session by generating a random key which will
    #be used by the browser to authenticate itself to the server
    #howver since facebook uses different session key in each request we can't use the session
    #nevertheless facebook sesssion always has the same unqie key for each different user 
    #so in order to use the session object we must create a new session object using that key
    #to retrive the user information 
    #since this only happens if fbsession is valid then we don't have to worry about 
    #who is sending this session key since the only people capable of creating valid fbsession
    #are facebook and classtalk since they are the only one with access to secret key
    user_session_id = fbsession.session_key.gsub(/[^\w\d]+/,'')
    if session.session_id != user_session_id
      new_session_options = request.send(:session_options_with_string_keys).merge("session_id"=>user_session_id,"new_session" => false)
      request.session=CGI::Session.new(request.cgi,new_session_options 
          )        
      request.session.instance_variable_get("@dbman").restore
      @session = request.session
      @response.session = @session
      instance_variable_set("@flash",@session["flash"] ||= FlashHash.new)     
      logger.debug "Retrived the permenant user session for  #{fbsession.session_user_id}"
      logger.debug "Session ID: #{session.session_id}"
    end
    if !logged_in_user
      @logged_in_user = User.new            
      @logged_in_user.id = get_session_uid
      @logged_in_user.save
      @new_user = true 
    end
    logged_in_user.stamp_access!
    if ENV['RAILS_ENV'] == "production" || !logged_in_user.is_tester?
      if fbparams['friends']
         session['friends'] = fbparams['friends']     
      else
         fbparams['friends'] = session['friends'] || ""
      end    
      logged_in_user.friends = fbparams['friends'].split(",").map{|f| f.to_i} || [0]
    else  
      if controller_name != "test"
        if session['persona_id']
            @logged_in_user = User.find(session['persona_id'])
            friends = "518241481 712975383 712456404 518239949 518328611 713015463 712574992".split(" ")  
            friends << "116202455"
            @logged_in_user.friends = friends
        else
            return_after :fb_redirect_to,:controller=>"test" 
        end
      end      
    end            
  end
  #whenever a request comes from a user, we must check their current school affiliations 
  #and their roles in each school. this needs to be done because a user can change their affiliations and 
  #their status within each school and since classtalk works by those facebook status it needs to be 
  #aware of them 
  #this requires the authenticate to be run
  def update_affiliations
     if fbsession.is_valid?  
       affiliations = fbsession.users_getInfo(:fields=>"affiliations",
      :uids=>logged_in_user.id).first["affiliations"].select{|s| s["type"] == "college"}      
      if logged_in_user.is_admin?
          session['fake_schools'] ||= []
          if params[:anid] and  (s = School.find(params[:anid].to_i) rescue nil) 
              session['fake_schools'] << s.id
          elsif params[:rnid]
              session['fake_schools'].delete(params[:rnid].to_i)
          end
          session['fake_schools'].uniq!          
          session['fake_schools'].each do |nid|
              affiliations << {"nid"=>nid,"status"=>"undergrad"}
          end
      end
      @user_supported_schools,@user_unsupported_schools,@closed_schools= School.instant(logged_in_user,affiliations)
      @user_supported_schools.instance_eval do 
            def default
              self.first
            end
            def get_ids
              @ids ||= self.map(&:id).sort  
            end
            def match_ids?(ids)
                @ids == ids.sort
            end
            def get_school id
                self.detect{|s| s.id == id}         
            end
            def include_schools?(schools)         
               schools = [schools] unless schools.is_a?(Array)
               schools.detect{|s| get_ids.include?(s.id)}
            end
            
      end

      logged_in_user.supported_schools =  @user_supported_schools           
    else
        @closed_schools = @user_supported_schools = @user_unsupported_schools = []        
    end
    @user_schools = @user_supported_schools + @user_unsupported_schools + @closed_schools
  end
  #based on whether the request if coming from canvas or an iframe 
  #we choose a different layout to render the actions  
  def choose_layout    
     
    layout = (!in_facebook_canvas? ? "iframe_layout" : "canvas_layout") + ".rhtml"
    layout    
  end
  #in case of an iframe rendering we facebook will inject the forms with necessary session information 
  #so when a form is submitted directly to our server we can verify the submittion but in case of an 
  #iframe we need to sign all the forms the same way so when a form is submitted within an iframe
  #we can verify them. 
  #TODO what about the ajax requests how can we sign them
  #We really don't need this since fbjs any except for one action that's course selection module
  def sign_forms
    if !in_facebook_canvas?
      hidden_fields = "<div class='signiture'>"
      signiture_hash.each do |k,v|
        hidden_fields << "<input type='hidden' name='#{k}' value='#{v}'/>"
      end      
      hidden_fields << "</div>"
      parsed_doc.search("form").prepend(hidden_fields)     
      response.body = parsed_doc.to_html
    end
  end
  #this will inject fbml message into the body of response 
  def insert_messages
#      if flash[:message_hash] and !flash[:message_hash].empty?
#        flash[:message_hash].each do |dom_id,message|
#          (parsed_doc/"##{dom_id}").append(message)      
#        end
#
#        response.body = parsed_doc.to_html
#      end
  end
  #Ajax will render a message and return fbml according to the parameters passed by
  #the client 
  #no authentication needed
  def render_msg 
      render :text=>fbml_msg_format(params[:type],params[:msgs].split("####"),{:title=>params[:title],:list=>params[:list] == "true"})
  end
  public :render_msg  
  #this method will keep a hash of messages 
  #these messages will be injected to the response body by the insert_messages after filter method
  #PARAMETERS id - the id of the dom for the messages to be injected to 
  #           type - the type of message 
  #           *args - a list of messages to be inserted
  #examples 
  def r_msg msg_type,*msgs        
     dom_id = msgs.last.is_a?(Hash) ? msgs.last.delete(:id) || "server_message" : "server_message"     
     final_message = fbml_msg_format(msg_type,msgs)
     flash[:message_hash] ||= {}
     flash[:message_hash][dom_id] = final_message
     flash[dom_id.to_sym] = final_message
  end

  def fbml_msg_format msg_type,*msgs    
     msgs = [msgs].flatten
     options = {:title=>nil,:list=>false}.update(msgs.last.is_a?(Hash) ? msgs.pop : {})
     msgs.map! do |msg|
        if msg.is_a?(ActiveRecord::Errors)
        
        end  
        if options[:list]
          msg = "<li><p>#{msg}</p></li>"
        end 
        msg       
     end
     final_message = if options[:list]
                        "<ul>#{msgs.join("")}</ul>"
                      else
                          "<p>#{msgs.join(", ")}</p>"
                      end                     
     if options[:title]  
        final_message =  "<div>#{options[:title]}</div>"  + final_message     
     end
     final_message = "<fb:#{msg_type.to_s}><fb:message>#{final_message}</fb:message></fb:#{msg_type.to_s}>"  
     final_message
  end
  def parsed_doc
    @parsed_doc ||= Hpricot(response.body)
  end

  def prepare_send_off   
    #fix all the styles
    #apply the patch for the style shift bug    
    #response.body = response.body.gsub(/\s+/,' ')
    return
    doc = Hpricot(response.body)
    styles = []
    (doc/"style").each do |s|
      styles << [s.inner_html,s['assetserver']]
    end    
    fixed_styles = ""
    styles.each do |style,asset_server|
      safe_styles,styles_with_url = parse_styles(style,asset_server)
      fixed_styles << safe_styles
      
    end
#    response.body = response.body.gsub(/\s+/,' ')
  end
  def parse_styles styles,asset_server=""
        styles = styles.gsub(/\s/,' ') || styles
        styles = styles.gsub(/\/\*.*?\*\//,'') || styles
        safe_styles = ""
        style_with_url = []
        styles.scan(/([^{]+)\{(.*?)\}/)do |selector,content|                    
          selector = selector.gsub(/#([^ ]+)/,'#' + APP_ID + '_\1') || selector
          if content.match(/url/)
            content = content.gsub(/url\((.*?)\)/,'url(' + asset_server  + '\1)') || content
            style_with_url << selector + "{" + content + "}"
          else
            safe_styles << selector + "{" + content + "}"
          end
        end
        return safe_styles,unsafe_styles
  end
  private
  #this is a helper method 
  #will call the method passed in as the first argument and then raise an exception
  #good for when trying to return an error message
  def raise_after method,*args
      send method,*args
      raise
  end
  #same as above but will return after calling method
  def return_after method,*args
     send method,*args
     raise ReturnAfterRenderException
  end
  #same method as above but it call the method r_msg 
  def raise_after_msg *args
      send :r_msg,*args
      raise
  end
  #renders something and nothing and return for fast handling of invalid stuff
  #this works by rewriting the rescue_action and catching return and after rendering
  def render_return text=nil   
    erase_render_results
    if text.is_a? Hash
        render text
    elsif text.is_a? String
      render :text=>text
    else
      render :nothing=>true
    end  
    raise ReturnAfterRenderException
  end  
  
  class ReturnAfterRenderException < Exception;end;
  def rescue_action(exception)    
    super if !exception.is_a?(ApplicationController::ReturnAfterRenderException) 
  end


end
#  class RequestTicket
#    require 'digest/md5'
#    attr_reader :number
#    def self.get_ticket(id) 
#      p 'retriving ticket with id ' + id.to_s
#      CACHE.get("ticket_#{id}")
#    end
#    def self.create(params,expiry_time=5.seconds.from_now)
#      ticket = self.new(params,expiry_time)
#      CACHE.set("ticket_#{ticket.number}",ticket)
#      p 'creating a ticket with id ' + ticket.number
#      return ticket
#    end
#    def expired?
#      Time.now > @expiry_time
#    end
#    def inject_to(params)
#      params.update(@fb_param_capture)
#    end
#    def initialize(params,expiry_time=5.seconds.from_now)
#      @number = Digest::MD5.hexdigest(Time.now.to_i.to_s)
#      @expiry_time = expiry_time
#      @fb_param_capture = params.inject({}) do |h1,a|
#        k,v = a              
#        if k =~ /fb_sig_.*/ 
#          h1[k] = v
#        end
#        h1
#      end
#    end
#  end