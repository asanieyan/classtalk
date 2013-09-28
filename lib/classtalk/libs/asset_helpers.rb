module Facebook
  module AssetHelper
    FBAssetServer = "http://static.ak.facebook.com"
    #these two methods are used by layouts two bring javascript and css libraries from
    #facebook, prefereblt we should have our own css in case they changes 
    #but it's okay for quick and dirty stuff
  #    def fb_import_js_lib *sources         
  #      sources.inject([]){ |html,src|
  #        html << javascript_include_tag(AssetHelper::FBAssetServer + "/js/" + src)
  #      }.join("\n")   
  #    end
  #    #can pass a hash parameter at the end to specify whether to link with the remote resource
  #    #or plain copy it to the page 
  #    #coping is needed when trying to use a css file in the facebook canvas
  #    #{:canvas=>true}
  #    def fb_import_css_lib(*sources)            
  #      sources.inject([]){ |html,src|
  #        html << stylesheet_link_tag(AssetHelper::FBAssetServer + "/css/" + src)
  #      }.join("\n")
  #    end
        

    def fb_remote_css *sheets    
      @lib_imports ||= {}
      require 'open-uri'
      styles = ""
      sheets.each do |sheet|
        next if @lib_imports[sheet]
        @lib_imports[sheet] = true
        styles << open(FBAssetServer + sheet).read rescue ""
      end
      #return content_tag(:style,styles,:assetserver=>FBAssetServer)
      parse_styles styles,FBAssetServer
    end
    def style_tag &block
        concat(parse_styles(capture(&block)),block.binding)
    end
    #this is used when importing a style sheet file to a canvas page 
    #we need to parse the imported stuff 
    #the id selector must be prepended with facebook application id 
    #the resources with url image must each be in a seperate style tag
    def fb_css *sheets        
        @lib_imports ||= {}
        styles = ""
        sheets.each do |sheet|
            next if @lib_imports[sheet]
            @lib_imports[sheet] = true
            path = File.join("public",stylesheet_path(sheet)).gsub(/\?\d+/,'')
            File.open(path,"r") do |f|
              styles << f.read
            end
        end
        #return content_tag(:style,styles,:assetserver=>ApplicationController::APP_ASSET_SERVER)
        parse_styles styles,ApplicationController::APP_ASSET_SERVER
    end 
    def fb_js *js
        @lib_imports ||= {}
        scripts = ""
        js.each do |j|
            next if @lib_imports[j]
            @lib_imports[js] = true
            path = File.join("public",javascript_path(j)).gsub(/\?\d+/,'')
            File.open(path,"r") do |f|
              scripts << f.read
            end
        end                
#        puts scripts
        javascript_tag(scripts) unless scripts == ""
        #return content_tag(:style,styles,:assetserver=>ApplicationController::APP_ASSET_SERVER)
        #parse_styles styles,ApplicationController::APP_ASSET_SERVER
    end 
    def url_for_app_asset(asset_path)
        ApplicationController::APP_ASSET_SERVER + asset_path   
    end  
    alias app_asset url_for_app_asset    
    def parse_styles styles,asset_server=""
        return "" if styles.size == 0
        styles = styles.gsub(/\s/,' ') || styles #get rid of whitespace
        styles = styles.gsub(/\/\*.*?\*\//,'') || styles #get rid of comments
        safe_styles = ""
        styles_with_url = []
        styles.scan(/([^{]+)\{(.*?)\}/)do |selector,content|                    
#          selector = selector.gsub(/#([^ ]+)/,'#' + ApplicationController::APP_ID + '_\1') || selector
          if content.match(/url/)
            content = content.gsub(/url\((.*?)\)/,'url(' + asset_server  + '\1)') || content
            styles_with_url << selector + "{" + content + "}"
          else
            safe_styles <<selector + "{" + content + "}"
          end
        end   
        return content_tag(:style,safe_styles) + styles_with_url.map{|s| content_tag(:style,s)}.join("")      
    end
  end
end