#enables post and get within any class
module Protocol
    require 'cgi'
    require 'net/http'
    require 'uri'
    require 'open-uri'    
    def reset_session
        
    end   
    def analyze(request,resp,analyze)
        @response = resp
        @request  = request
        
        reset_session if analyze
        return @response.body
    end

    def set_cookie cook=nil      
      if cook 
        @cookie = get_cookie(cook)      
      elsif @response['set-cookie']
#         p 'her'
         @cookie = @response['set-cookie']
#        CGI::Cookie::parse(@response['set-cookie']).each do |k,v|  
#           puts k.to_s + " = " + v.value.inspect
#        end    
         p 
      end  
##      cook = CGI::Cookie::new(CGI::Cookie.parse(cook))
    end
    def get_cookie(string)
        if string.match(/Cookie/)
          string.gsub(/Cookie: (.*)/,'\1').strip
        else
          string
        end        
    end

    HeaderFields = {} 
    def login addr,params,&block
        pre_request = @request
        post(addr,params,{:analyze=>false})
        set_cookie
        if pre_request.method == "POST"
            post(pre_request['Full-Path'],pre_request.body)
        else
            get(pre_request['Full-Path'])
        end
    end           
    def post(addr,params,options={}) 
      analyze = options[:analyze].nil? ? true : options.delete(:analyze)
      options.update('Cookie'=>@cookie) if @cookie
      options.update('Full-Path'=>addr)
      require 'net/https'
      url = URI.parse(addr)
      http = Net::HTTP.new(url.host,url.port)
      http.use_ssl = true if addr =~ /https/
      path = url.query ?  url.path + "?" + url.query : url.path  
      post = Net::HTTP::Post.new(path,options)           
      if params.is_a?(String) 
        post.body=params
        post.content_type = 'application/x-www-form-urlencoded'
      else
        post.set_form_data(params)      
      end
      http.start do |http|
         res = http.request(post)         
         analyze(post,res,analyze)
      end
    end
    def get  addr,options={}             
       analyze = options[:analyze].nil? ? true : options.delete(:analyze)
       begin
         klass = self.class.to_s
         klass = klass.gsub(/([A-Z][a-z]+)/,'\1_').split("_")
         klass.pop
         klass = klass.map{|s| s.downcase}.join("_")
         dir = "lib/net_support/#{klass}/#{addr}"
       rescue
         dir = rand(10000).to_s
       end
       if File.exists?(dir)
          if (File.extname(dir)) == ".yml"
            YAML::load_file(dir)
          else  
            open(dir)
          end
       else
          options.update('cookie'=>@cookie) if @cookie          
          options.update('Full-Path'=>addr)
          require 'net/https'
          url = URI.parse(addr)
          path = url.query ?  url.path + "?" + url.query : url.path
          http = Net::HTTP.new(url.host,url.port)
          http.use_ssl = true  if addr =~ /https/
          http.start do |http|
             request = Net::HTTP::Get.new(path,options)
             res = http.request(request)
             analyze(request,res,analyze)
          end
       end
       #Net::HTTP.get(URI.parse(addr))             
    end
end
