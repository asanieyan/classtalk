module Facebook
  module UrlRewrite        
    #all the request coming from facebook is signed 
    #also facebook will sign all the forms and ajax requests urls 
    #however sometimes we need to send the user directly to the site
    #thats why we need to send fb_sig parameters with a signiture
    #previsouly i would use the available signiture however that's not good 
    #since it contains the list of friends which can be very big and not possible with GET requests 
    #so we need to sign our params that resemebles an IFRAM GET Request
    def sign_fb_params
#      fb_sig_in_iframe=1 
#      fb_sig_time=1186713543.2965 
#      fb_sig_user=116202455 
#      fb_sig_profile_update_time=1186625252 
#      fb_sig_session_key="ab101e7318c1e38e08aeb973-116202455"
#      fb_sig_expires=0 
#      fb_sig_api_key="a8bec8b6ea07ff6abe3fbdee662f91b4" 
#      fb_sig_added=1 
#      fb_sig="caf936b60c1084c824b3a9e8e39ffc91"    
    end
    def to_query_string(params={})
       params.update(signiture_hash).to_a.map { |param|
                                  param.join("=")
                                  }.join("&")
    end
    #return a new signiture based on some of the parameters required to 
    #create a session
    def signiture_hash
      @signiture_hash ||= begin
          dup =  fbparams.dup
          dup.delete("friends")
          fb_sig = fbsession.param_signature(dup)
          new_hash = dup.inject({}) { |h,e|
              k,v = e
              h["fb_sig_#{k}"] = v
              h
          }.update("fb_sig"=>fb_sig)
        end
    end
    def signed_url url
      return url_for(url) if url.is_a? String
      url_for(url.update(signiture_hash))
    end
    def app_url_for url,sign=true      
      if url.is_a?(String) and !url.match(/^http/)
          url = "/" + url unless url.match(/^\//)
          return ApplicationController::APP_SERVER + url
      elsif url.is_a?(String)
          return url
      end
      url[:host] = ""
      url[:protocol] = ""
      url.update(signiture_hash) if sign
      ApplicationController::APP_SERVER + url_for(url)
    end 
    alias app_url app_url_for
    def ajax_url url
      app_url url,false
    end
    alias ct_url  app_url_for
    def fb_url_for url          
      if url.is_a?(String) and !url.match(/^http/)
          url = "/" + url unless url.match(/^\//)
          return ApplicationController::FACEBOOK_APP_HOST + ApplicationController::FACEBOOK_APP_URL + url
      elsif url.is_a?(String)
          return url
      end
      url[:host] = ""
      url[:protocol] = ""
      url[:escape] = false;
      str_url = ApplicationController::FACEBOOK_APP_HOST + ApplicationController::FACEBOOK_APP_URL + url_for(url)
    end
    alias fb_url  fb_url_for
    def fb_redirect_to url
      require 'uri'
#      render :text=>"<fb:redirect url='#{URI::encode(fb_url_for(url))}' />"
      render :text=>"<fb:redirect url=\"#{fb_url_for(url)}\" />"  
    end
  end  
  module UrlHelper
    include UrlRewrite
    def fb_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference) 
        new_link_to name,fb_url_for(options),html_options,parameters_for_method_reference        
    end
    def link_to_app(name, options = {}, html_options = nil, *parameters_for_method_reference) 
        new_link_to name,app_url_for(options),html_options
    end
    #temporary until fb  fix their stuff
#    def link_to_function name,method
#        id = "func" + rand(10000).to_s
#        link_to(name,"#",:id=>id) + 
#        javascript_tag(<<-eof
#                  document.getElementById('#{id}').addEventListener('click',function(){
#                    #{method};
#                    return false; 
#                  })
#        eof
#        )
#    end
    def new_link_to(name, options = "", html_options = nil, *parameters_for_method_reference) 
        js_click = ""
        if html_options && html_options[:confirm] 
            html_options[:id] ||= "link#{rand(10000)}"
            title = html_options.delete(:confirm)
            if title.is_a?(Array)
                title,content = title
            else
                content = ""
            end
            js_click = javascript_tag <<-eof
                  document.getElementById('#{html_options[:id]}').addEventListener('click',function(){
                    new Dialog(Dialog.POP_DIALOG).showChoice('#{title}','#{content}').onconfirm = function(){document.setLocation(this.getHref())}.bind(this);
                    return false; 
                  })                 
            eof
        end
        link_to(name,options,html_options,parameters_for_method_reference) + js_click
    end
  end  
end