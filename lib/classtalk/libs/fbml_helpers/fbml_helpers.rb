module Facebook
  module FBMLHelper
    def tag_wrapper tag_name,content,tag_options,&block
        if block_given?
          content = capture(&block)          
          concat(content_tag(tag_name,content,tag_options),block.binding)
        else
          content_tag(tag_name,content,tag_options)
        end
    end
    def fbml_dialog_form invoker,title,optios,&block
        dialog_id = options.delete(:dialog_id) || rand(10000)
        form_id = options.delete(:form_id) || dialog_id  + 1 
        submit_tag = options.delete(:submit) || "submit" 
        invoker = fbml_dialog_invoker(invoker)
        title = fbml_dialog_title(title)
        content =  fbml_dialog_content("<form id='#{form_id}' action=>'#{fb_url_for(options[:url])}' method='POST'>" + capture(&block) + "</form>")
        buttons = fbml_dialog_close(options.delete(:close) || "Cancel") + fbml_dialog_submit(submit_tag,form_id)
        concat(fbml_dialog(dialog_id,false,invoker+title+content+buttons),block.binding)        
    end
    def remote_fbml_dialog_form invoker,title,options={},&block
        dialog_id = options.delete(:dialog_id) || rand(10000)
        form_id = options.delete(:form_id) || dialog_id  + 1 
        submit_tag = options.delete(:submit) || "submit"       
        invoker = fbml_dialog_invoker(invoker)
        title = fbml_dialog_title(title)
        content =  fbml_dialog_content("<form id='#{form_id}'>" + capture(&block) + "</form>") 
      
        buttons = fbml_dialog_close(options.delete(:close) || "Cancel") + fbml_dialog_submit_remote(submit_tag,options.update(:form=>form_id))
        concat(fbml_dialog(dialog_id,false,invoker+title+content+buttons),block.binding)
    end
    def fbml_dialog id,no_cancel_button = false,content="",&block
       tag_options = {:id=>id,:no_cancel_button=>no_cancel_button}
       tag_wrapper "fb:dialog",content,tag_options,&block
    end
    def fbml_dialog_invoker text
        fbml_dialog_display(text.gsub(/\{(.*?)\}/,fbml_dialog_link('\1')))
    end
    def fbml_dialog_display invoker="",&block
        tag_wrapper "fb:dialog-display",invoker,nil,&block
    end
    def fbml_dialog_link name
          link_to name,"#",:onclickdialog=>1
    end
    def fbml_dialog_title title="",&block
        tag_wrapper "fb:dialog-title",title,nil,&block
    end
    def fbml_dialog_content content="",&block
      tag_wrapper "fb:dialog-content",content,nil,&block
    end   
    def fbml_dialog_close value="Cancel"
        fbml_dialog_button value,"button",{:close_dialog=>1}
    end 
    def fbml_dialog_submit value,form_id
        fbml_dialog_button value,"submit", {:form_id=>form_id}
    end
    def fbml_dialog_submit_remote value,options={}
        new_options = {}
        new_options[:clickrewriteurl] = app_url_for(options.delete(:url) || "")
        new_options[:clickrewriteid] = options.delete(:update) 
        new_options[:clickrewriteform] = options.delete(:form)       
        fbml_dialog_button value,"submit", new_options
    end
    def fbml_dialog_button_to value,url
        fbml_dialog_button value,"submit",{:href=>fb_url_for(url)}
    end    
    def fbml_dialog_button value,type,options={}
      tag_wrapper "fb:dialog-button",nil,options.update(:type=>type,:value=>value)
    end

    def fbml_dashboard
      elements = {:title=> [],:actions=> [],:help=>[],:button=>[]}
      yield(elements)
      actions = elements.delete(:actions)
      help = elements.delete(:help)
      title = elements.delete(:title)
      button = elements.delete(:button)      
      help_name,help_url = help.shift  
      button_name,button_url = button.shift 
      html = ""      
      html << (actions.map{|a_name,a_link| content_tag("fb:action",
                a_name,:href=>a_link)}.join("")) if not actions.empty?
      html << (content_tag("fb:help","",:title=>help_name,:href=>help_url)) if help_name && help_url
      
      html << (content_tag("fb:create-button",button_name,:href=>button_url)) if button_name &&  button_url      
      content_tag("fb:dashboard",html)      
      
    end
    def get_uid_substitue uid
      if uid.to_s == "me"
        return "loggedinuser" 
      elsif uid.to_s == "profile_owner"  
        return "profileowner"
      else
        return uid
      end
    end    
    def fbml_if_is_friends_with_viewer uid,content="",options={},&block
        fbml_else = fbml_else(options.delete(:else)) if options[:else]
        
    end 
    def fbml_if_can_see uid,what="search",content="",&block
        content = capture(&block) if block_given?
        content = content_tag("fb:if-can-see",content,{:what=>what,:uid=>uid})
        return concat(content,block.binding) if block_given?
        return content
    end
    def fbml_else content="",&block
        content = capture(&block) if block_given?
        content = content_tag("fb:else",content)
        return concat(content,block.binding) if block_given?
        return content    
    end
    def fbml_profile_pic uid=:me,options={}
      options[:uid] = get_uid_substitue(uid)
      content_tag("fb:profile-pic","",options)      
    end
    def fbml_redirect_to url
        url = fb_url_for(url)
        content_tag("fb:redirect","",:url=>url)
    end
    def fbml_pronoun uid,options={}
      options[:uid] = uid
      content_tag("fb:pronoun","",options)
    end
    def fbml_time time,options={}
        verb = options.delete(:verb)
        tz = options.delete(:tz)
        if verb || options[:pre]
          verb = verb.to_s
          verb += " " unless options[:pre]
          verb += if time.to_date == Time.now.utc.to_date
                    "at " 
                 else
                    "on "
                 end                   
        end
        
        verb.to_s + content_tag("fb:time","",:t=>time.to_i,:tz=>tz)
        
    end
    def fbml_name uid=:me,options={}
        uid = get_uid_substitue(uid)        
        options[:uid] = uid        
        content_tag("fb:name","",options)
    end
    def fbml_user_link uid,options={}
        options[:uid]=uid
        content_tag("fb:userlink","",options)
    end
    def fbml_ref options={}
      options[:url] = fb_url_for(options[:url]) if options[:url]
      content_tag(:fb_ref,"",options)
    end
    def fbml options={},&block
      if options.is_a? Hash
        version = options[:version] || "1.0"
        content = options[:content] || ""
      else
        version = "1.0"
        content = options.to_s
      end
      if block_given?
        concat(content_tag("fb:fbml",capture(&block),:version=>version),block.binding)
      else 
        content_tag("fb:fbml",content,:version=>version)
      end            
    end
    def fbml_js_string var,value="",&block
        value = capture(&block) if block_given?
        html = content_tag("fb:js-string",value,:var=>var)
        return concat(html,block.binding) if block_given?
        return html
    end
    def fbml_explain message="",&block
      message = fbml_message(message,&block)
      block_given? ?  concat(content_tag("fb:explanation",message),block.binding) : 
                      content_tag("fb:explanation",message)
    end
    def fbml_success message="",&block
      message = fbml_message(message,&block)
      block_given? ?  concat(content_tag("fb:success",message),block.binding) : 
                      content_tag("fb:success",message)  
    end
    def fbml_error message="",&block
      message = fbml_message(message,&block)
      block_given? ?  concat(content_tag("fb:error",message),block.binding) : 
                      content_tag("fb:error",message)  
    end
    def fbml_message message="",&block               
       message ||= ""
       if message.is_a?(Hash)
          title = message[:title] ? content_tag(:strong,message.delete(:title))  : ""
          text = message[:text] ? content_tag(:p,message.delete(:text))  : ""
          message = title + text 
        end        
        if block_given?               
          message += content_tag(:p,capture(&block))
        end
        content_tag("fb:message",message)
    end    
    def fbml_iframe src,options={},&block
      src[:only_path] = false if src.is_a?(Hash)
      if options[:smartsize].nil? 
         options[:smartsize] = true
      end
      options[:src] = url_for(src)
      options[:style] = (options[:style] || "") + ";border:none"
      options[:frameborder] = 0
      if not block_given?
        content_tag("fb:iframe","",options)
      else      
        concat(content_tag("fb:iframe",capture(&block),options),block.binding)       
      end
    end
    def fb_tabs     
      yield( tabs = [])
      html = ""      
      selected_tab = nil
      tabs.map! do |tab_name,tab_url,tab_options|
        href = url_for(tab_url)  
        tab = (tab_options || {}).update(:title=>tab_name,:href=>fb_url_for(tab_url))

        if  check = tab.delete(:check) 
           selected_tab = tab if eval(check)
        else request.request_uri == href         
          selected_tab = tab
        end 
        tab
      end
      selected_tab = tabs.first unless selected_tab
      selected_tab[:selected] = true      
      if selected_tab[:partial]
        name,var = selected_tab.delete(:partial)
        @selected_tab_content = render_p(name,var)
        
      end
         
      content_tag("fb:tabs",tabs.map{|t| content_tag("fb:tab-item","",t)}.join("")) 
    end
    alias fbml_tabs fb_tabs
  end    
end