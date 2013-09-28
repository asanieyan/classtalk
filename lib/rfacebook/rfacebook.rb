#require File.join(File.dirname(__FILE__) ,"facebook_web_session")

require "digest/md5"
require "net/https"
require "cgi"
require "hpricot"

module RFacebook
  API_SERVER_BASE_URL       = "api.facebook.com"
  API_PATH_REST             = "/restserver.php"
  
  WWW_SERVER_BASE_URL       = "www.facebook.com"
  WWW_PATH_LOGIN            = "/login.php"
  WWW_PATH_ADD              = "/add.php"
  WWW_PATH_INSTALL          = "/install.php"
  
  class FacebookSession 
    
    # error handling accessors
    attr_reader :last_call_was_successful, :last_error,:response
    attr_writer :suppress_exceptions
    
    # SECTION: Exceptions
      
    class RemoteException < Exception; end
    class ExpiredSessionException < Exception; end
    class NotActivatedException < Exception; end
    
    # SECTION: Public Methods  
    
    # Function: initialize
    #   Constructs a FacebookSession
    #
    # Parameters:
    #   api_key                       - your API key
    #   api_secret                    - your API secret
    #   suppress_exceptions           - boolean, set to true if you don't want exceptions to be thrown (defaults to false)
    
    def initialize(api_key, api_secret, suppress_exceptions = false)
      
      # required parameters
      @api_key = api_key
      @api_secret = api_secret
      
      # calculated parameters
      @api_server_base_url = API_SERVER_BASE_URL
      @api_server_path = API_PATH_REST
          
      # optional parameters
      @suppress_exceptions = suppress_exceptions
      
      # initialize internal state
      @last_call_was_successful = true
      @last_error = nil
      @session_expired = false
      
    end
    
    def session_expired?
      return (@session_expired == true)
    end
  
    # SECTION: Public Abstract Interface
  
    def is_valid?
      raise Exception
    end
    
    def session_key
      raise Exception
    end
    
    def session_user_id
      raise Exception
    end
    
    def session_expires
      raise Exception
    end
    
    def session_uid # deprecated
      return session_user_id
    end
    def is_logged_in_user? uid
      session_user_id == uid
    end
    # SECTION: Protected Abstract Interface
    protected
    
    def get_secret(params)
      raise Exception
    end
    
    def is_activated?
      raise Exception
    end
    
    def is_me? uid 
      return session_user_id.to_s == uid.to_s
    end  
       
    # SECTION: Protected Concrete Interface
    
    # Function: method_missing
    #   This allows *any* Facebook method to be called, using the Ruby
    #   mechanism for responding to unimplemented methods.  Basically,
    #   this converts a call to "auth_getSession" to "auth.getSession"
    #   and does the proper API call using the parameter hash given.  
    def method_missing(methodSymbol, *params)
      methodString = methodSymbol.to_s.gsub!("_", ".")
      # TODO: check here for valid method names
      call_method(methodString, params.first.update(:format=>"JSON"))
    end

    # Function: call_method
    #   Sets up the necessary parameters to make the POST request to the server
    #
    # Parameters:
    #   method              - i.e. "users.getInfo"
    #   params              - hash of key,value pairs for the parameters to this method
    #   use_ssl             - set to true if the call will be made over SSL
    def call_method(method, params={}, use_ssl=false)
      
      # ensure that this object has been activated somehow
      if (!method.include?("auth") and !is_activated?)
        raise NotActivatedException, "You must activate the session before using it."
      end
      
      # set up params hash
      params = params ||= {}
      params[:method] = "facebook.#{method}"
      params[:api_key] = @api_key
      params[:v] = "1.0"
      
      if (method != "auth.getSession" and method != "auth.createToken")
        params[:session_key] = session_key
        params[:call_id] = Time.now.to_f.to_s
      end
      
      # convert arrays to comma-separated lists
      params.each{|k,v| params[k] = v.join(",") if v.is_a?(Array)}
      
      # set up the param_signature value in the params
      params[:sig] = param_signature(params)
      
      # prepare internal state
      @last_call_was_successful = true
      #@last_error = nil    
      # do the request
      @response = response = post_request(@api_server_base_url, @api_server_path, method, params, use_ssl)       
      if params[:format] == "JSON"
        json = JSON.parse(response) rescue {}
        if json.is_a?(Hash) and json["error_msg"]
          @last_call_was_successful = false
          code = json["error_code"]
          msg = json["error_msg"]
          @last_error = "ERROR #{code}: #{msg} (#{method.inspect}, #{params.inspect})"
          @last_error_code = code
          raise RemoteException, @last_error unless @suppress_exceptions == true
        end
        return json
      end
  #    else it is a xml format
  
      xml = Hpricot(response)
      # error checking    
      if xml.at("error_response")
        @last_call_was_successful = false
        code = xml.at("error_code").inner_html
        msg = xml.at("error_msg").inner_html
        @last_error = "ERROR #{code}: #{msg} (#{method.inspect}, #{params.inspect})"
        @last_error_code = code
        
        # check to see if this error was an expired session error
        if code.to_i == 102
          @session_expired = true
          raise ExpiredSessionException, @last_error unless @suppress_exceptions == true
        end
        
        # otherwise, just throw a generic expired session
        raise RemoteException, @last_error unless @suppress_exceptions == true
        
        return nil
      end
      
      return xml
    end
   
    
    public
  
    # SECTION: Private Concrete Interface
    
    # Function: post_request
    #   Does a post to the given server/path, using the params as formdata
    #
    # Parameters:
    #   api_server_base_url         - i.e. "api.facebook.com"
    #   api_server_path             - i.e. "/restserver.php"
    #   method                      - i.e. "facebook.users.getInfo"
    #   params                      - hash of key/value pairs that get sent as form data to the server
    #   use_ssl                     - set to true if you want to use SSL for this request
    def post_request(api_server_base_url, api_server_path, method, params, use_ssl)
      
      # get a server handle
      port = (use_ssl == true) ? 443 : 80
      http_server = Net::HTTP.new(@api_server_base_url, port)
      http_server.use_ssl = use_ssl
      
      # build a request
      http_request = Net::HTTP::Post.new(@api_server_path)
      http_request.form_data = params
      response = http_server.start{|http| http.request(http_request)}.body
      # return the text of the body
      return response
      
    end
    
    # Function: param_signature
    #   Generates a param_signature for a call to the API, per the spec on Facebook
    #   see: <http://developers.facebook.com/documentation.php?v=1.0&doc=auth>
    def param_signature(params)    
      return generate_signature(params, get_secret(params));
    end
    
    def generate_signature(hash, secret)
      
      args = []
      hash.each do |k,v|
        args << "#{k}=#{v}"
      end
      sortedArray = args.sort
      requestStr = sortedArray.join("")
      return Digest::MD5.hexdigest("#{requestStr}#{secret}")
      
    end
  
  end 
  class FacebookWebSession < FacebookSession
    
      # SECTION: Properties
      
      def initialize(api_key, api_secret, suppress_exceptions = false)
        super(api_key,api_secret,suppress_exceptions)
        @memcached_session = {}
      end
      def [](key)
        @memcached_session[key]
      end
      def []=(key,value)
         @memcached_session[key] = value
      end
      def session_key
        return @session_key
      end
    
      def session_user_id
        return @session_uid
      end
    
      def session_expires
        return @session_expires
      end
      
      # SECTION: URL Getters
      
      # Function: get_login_url
      #   Gets the authentication URL
      #
      # Parameters:
      #   options.next          - the page to redirect to after login
      #   options.popup         - boolean, whether or not to use the popup style (defaults to true)
      #   options.skipcookie    - boolean, whether to force new Facebook login (defaults to false)
      #   options.hidecheckbox  - boolean, whether to show the "infinite session" option checkbox
      def get_login_url(options={})
  
        # handle options
        nextPage = options[:next] ||= nil
        popup = (options[:popup] == nil) ? false : true
        skipcookie = (options[:skipcookie] == nil) ? false : true
        hidecheckbox = (options[:hidecheckbox] == nil) ? false : true
        frame = (options[:frame] == nil) ? false : true
        canvas = (options[:canvas] == nil) ? false : true
      
        # url pieces
        optionalNext = (nextPage == nil) ? "" : "&next=#{CGI.escape(nextPage.to_s)}"
        optionalPopup = (popup == true) ? "&popup=true" : ""
        optionalSkipCookie = (skipcookie == true) ? "&skipcookie=true" : ""
        optionalHideCheckbox = (hidecheckbox == true) ? "&hide_checkbox=true" : ""
        optionalFrame = (frame == true) ? "&fbframe=true" : ""
        optionalCanvas = (canvas == true) ? "&canvas=true" : ""
      
        # build and return URL
        return "http://#{WWW_SERVER_BASE_URL}#{WWW_PATH_LOGIN}?v=1.0&api_key=#{@api_key}#{optionalPopup}#{optionalNext}#{optionalSkipCookie}#{optionalHideCheckbox}#{optionalFrame}#{optionalCanvas}"
      
      end
      
      def get_install_url(options={})
      
        # handle options
        nextPage = options[:next] ||= nil
      
        # url pieces
        optionalNext = (nextPage == nil) ? "" : "&next=#{CGI.escape(nextPage.to_s)}"
      
        # build and return URL
        return "http://#{WWW_SERVER_BASE_URL}#{WWW_PATH_INSTALL}?api_key=#{@api_key}#{optionalNext}"
      
      end
    
  
      # SECTION: Callback Verification Helpers
      
      def get_fb_sig_params(originalParams)

        # setup
        timeout = 5.years#2.hours #3.seconds #48*3600
        namespace = "fb_sig"
        prefix = "#{namespace}_"
        # get the params prefixed by "fb_sig_" (and remove the prefix)
        sigParams = {}
        originalParams.each do |k,v|
          oldLen = k.length
          newK = k.sub(prefix, "")                  
          if oldLen != newK.length            
            sigParams[newK] = v
          end
        end
        # handle invalidation
        if (timeout and (sigParams["time"].nil? or (Time.now.to_i - sigParams["time"].to_i > timeout.to_i)))
          # invalidate if the timeout has been reached
          sigParams = {}
        end
        
        if !sig_params_valid?(sigParams, originalParams[namespace])
          # invalidate if the signatures don't match
          sigParams = {}
        end
        
        return sigParams
        
      end
    
    
    
      # SECTION: Session Activation
    
      # Function: activate_with_token
      #   Gets the session information available after current user logs in.
      # 
      # Parameters:
      #   auth_token    - string token passed back by the callback URL
      def activate_with_token(auth_token)
        result = call_method("auth.getSession", {:auth_token => auth_token})
        if result != nil
          @session_uid = result.at("uid").inner_html
          @session_key = result.at("session_key").inner_html
          @session_expires = result.at("expires").inner_html
        end
      end
    
      # Function: activate_with_previous_session
      #   Sets the session key directly (for example, if you have an infinite session key)
      # 
      # Parameters:
      #   key    - the session key to use
      def activate_with_previous_session(key, uid=nil, expires=nil)
        
        # TODO: what is a good way to handle expiration?
        #       low priority since the API will give an error code for me...
        
        # set the session key
        @session_key = key
      
        # determine the current user's id
        if uid
          @session_uid = uid
        else
          result = call_method("users.getLoggedInUser")
          @session_uid = result.at("users_getLoggedInUser_response").inner_html
        end
        #@memcached_session = ActionController::CgiRequest.new(CGI.new,ActionController::Base.session_options.merge(:session_id=>@session_key.to_s.gsub('-',''))).session
        
      end
    
      def is_valid?
        return (is_activated? and !session_expired?)
      end
    
    
    
    
    
    
      # SECTION: Protected methods
      protected
    
      def is_activated?
        return (@session_key != nil)
      end
    
      # Function: get_secret
      #   Template method, used by super::signature to generate a signature
      def get_secret(params)
        return @api_secret
      end
      
      def sig_params_valid?(sigParams, expectedSig)
        return (sigParams and expectedSig and generate_signature(sigParams, @api_secret) == expectedSig)
      end
    
    end
  module RailsControllerExtensions
    
        
    # SECTION: Exceptions
    
    class APIKeyNeededException < Exception; end
    class APISecretNeededException < Exception; end
    class APIFinisherNeededException < Exception; end
    
    # SECTION: Template Methods (must be implemented by concrete subclass)
    
    def facebook_api_key
      raise APIKeyNeededException
    end
    
    def facebook_api_secret
      raise APISecretNeededException
    end
    
    def finish_facebook_login
      raise APIFinisherNeededException
    end
    
    
    
    # SECTION: Required Methods
    
    def fbparams
      
      @fbparams ||= {};
      
      # try to get fbparams from the params hash
      if (@fbparams.length <= 0)
        @fbparams = fbsession.get_fb_sig_params(params)
#        if @fbparams["profile_update_time"]
#           @fbparams["profile_update_time"] = Time.at(@fbparams["profile_update_time"].to_i).utc
#        end
      end
      
      # else, try to get fbparams from the cookies hash
      # TODO: we don't write anything into the cookie, so this is kind of pointless right now
      if (@fbparams.length <= 0)
        @fbparams = fbsession.get_fb_sig_params(cookies)
      end
      
      return @fbparams
      
    end

    def fbsession
      
      if !@fbsession
        
        # create a session no matter what
        @fbsession = FacebookWebSession.new(facebook_api_key, facebook_api_secret)
        
        # then try to activate it somehow (or retrieve from previous state)
        # these might be nil
        facebookUid = fbparams["user"]
        facebookSessionKey = fbparams["session_key"]
        expirationTime = fbparams["expires"]
        
        if (facebookUid and facebookSessionKey and expirationTime)
          # Method 1: we have the user id and key from the fb_sig_ params
          @fbsession.activate_with_previous_session(facebookSessionKey, facebookUid, expirationTime)
          
        elsif (!in_facebook_canvas? and session[:rfacebook_fbsession])
          # Method 2: we've logged in the user already
          @fbsession = session[:rfacebook_fbsession]
          
        end  
        
      end
      
      return @fbsession
      
    end
    
    # SECTION: Helpful Methods
    def in_facebook_canvas?
      return (fbparams["in_canvas"] != nil)
    end        
    def in_facebook_frame?
      return (fbparams["in_iframe"] != nil || fbparams["in_canvas"] != nil)
    end    
#    def handle_facebook_login
#
#      if (params["auth_token"] and !in_facebook_canvas?)
#        
#        # create a session
#        session[:rfacebook_fbsession] = FacebookWebSession.new(facebook_api_key, facebook_api_secret)
#        session[:rfacebook_fbsession].activate_with_token(params["auth_token"])
#        
#        # template method call upon success
#        if session[:rfacebook_fbsession].is_valid?
#          finish_facebook_login
#        end
#        
#      end
#      
#    end    
#    def require_facebook_login
#      
#      # handle a facebook login if given (external sites and iframe only)
#      handle_facebook_login
#      
#      if !performed?
#        # try to get the session
#        sess = fbsession
#      
#        # handle invalid sessions by forcing the user to log in      
#        if !sess.is_valid?
#          if in_facebook_canvas?
#            render :text => "<fb:redirect url=\"#{sess.get_login_url(:canvas=>true)}\" />"
#            return false
#          else
#            redirect_to sess.get_login_url
#            return false
#          end
#        end
#      end
#      
#    end    
    def require_facebook_install
      sess = fbsession
      if (in_facebook_canvas? and !sess.is_valid?)
        render :text => "<fb:redirect url=\"#{sess.get_install_url}\" />"
      end
    end
    
  end
  
end