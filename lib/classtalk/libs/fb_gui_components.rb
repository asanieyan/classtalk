module Facebook
  module GuiComponents
  private
    def get_values *args
        
    end    
  public
    #Media Header    
#    def fb_media_header title,image
#      html1 = image ? content_tag(:div,image,:class=>"picture") : ""
#      html2 = content_tag(:div,content_tag(:h2,title),:class=>"media_gray_bg clearfix")
#      actions = []
#      yield(actions)
#      unless actions.empty?
#          actions  = actions.map {|a_name,a_link,a_option|
#                  fb_link_to a_name,a_link,a_option
#          
#          }.join(fb_pipe)
#          html2 << content_tag(:div,actions,:class=>"media_actions clearfix")
#      end
#      content_tag(:div,html1 + content_tag(:div,html2,:class=>"user_info"),:class=>"media_header clearfix")
#    end 
#    def random_tag(weight)
#      
#    end
#    def fb_random_tags
#      tags = []      
#      
#    end
    def fb_media_header
        e = {:image=>[],:actions=>[],:title=>[]}
        yield(e)
        image = content_tag(:div,e[:image].shift || "",:class=>"picture")
        title = content_tag(:div,content_tag(:h2,e.delete(:title).first),:class=>"media_gray_bg clearfix")
        actions = content_tag(:div,e.delete(:actions).map{|a_name,a_url| link_to(a_name,fb_url_for(a_url)) }.join(fb_pipe),:class=>"media_action clearfix")
        content_tag(:div,image + content_tag(:div,title+actions,:class=>"user_info"),:class=>"media_header clearfix")        
    end       
    def fb_uber_tab 
    
    end

    def fb_users_table type=:friend,&block

        if type == :search             
             filter = []
             concat(content_tag(:div,
                              content_tag(:div,
                                    content_tag(:div,capture(filter,&block),:class=>"column results")+ 
                                    content_tag(:div,filter.first || "",:class=>"column filters"),
                              :class=>"search_results clearfix filters_active"),
                          :class=>"ubersearch"),
                    block.binding)        
        else
             concat(content_tag(:div,capture(&block),:id=>"friendtables"),block.binding)
        end
    end
    def wrap_link(link,tag=nil)
        link = tag ? content_tag(tag,link) : link          
    end
    def put_fb_user_default_links user,links,tag=nil
         return links if logged_in_user.new_record?
         links.unshift [wrap_link(fb_link_send_message(user.id),tag)] unless user.id == logged_in_user.id
          if logged_in_user.id == user.id
              poke = "Poke yourself!"
          else
              poke = "Poke " + fbml_pronoun(user.id,:objective=>true) + "!"
          end
          links.unshift wrap_link(fb_link_poke(user.id,poke),tag)
          links.unshift fbml_if_can_see(user.id,"friends",wrap_link(fb_link_see_friends(user.id),tag))
          if logged_in_user.id != user.id                                                                                      
              links.unshift(logged_in_user.friends_with(user.id)? wrap_link(fb_link_remove_friend(user.id),tag) : wrap_link(fb_link_add_friend(user.id),tag))
              #wrap_link(links.first,tag)
          end          
    end
    def fb_result_table user,options={},&block
          options = {:default_links=>true}.update(options.symbolize_keys!)
          e = {:labels=>[],:actions=>[]}
          block.call(e) if block_given?          
          user_image = content_tag(:div,fbml_profile_pic(user.id,:size=>"small"),:class=>"image")
          user_info  = content_tag(:dt,"Name:") + content_tag(:dd,fbml_name(user.id,:useyou=>false),:class=>"result_name")
          e[:labels].each do |name,desc|
              if desc == nil
                  desc = name
                  name = nil                                         
              end           
              user_info << content_tag(:dt,(name ? "#{name}:" : ""))
              user_info << content_tag(:dd,desc)              
          end
          user_info = content_tag(:div,content_tag(:dl,user_info,:class=>"clearfix"),:class=>"info")
          action_links = []
          if options[:default_links]  
            put_fb_user_default_links(user,action_links,:li)                     
          end
          
          e[:actions].each do |a_name,a_url,a_options|                
                action_links << wrap(fb_link_to(a_name,a_url,options),:li)
          end
          user_actions = content_tag(:ul,action_links.join(""),:class=>"actionspro")
          return content_tag(:div,user_image+user_info+user_actions,:class=>"result clearfix")               
    end
    def fb_user_table user,options={},&block
          
          options = {:default_links=>true}.update(options.symbolize_keys!)
          e = {:labels=>[],:actions=>[]}
          links = []
          block.call(e) if block_given?
          user_table = table_tag(:cols=>3,
                    :col1=>{:class=>"image"},
                    :col2=>{:class=>"info"},
                    :col3=>{:class=>"actions"}){ |cols|                                                             
                    cols << fbml_profile_pic(user.id,:size=>"small")
                    cols.push table_tag(:cols=>2){|inner_cols| 
                                   inner_cols.add "Name:",{:class=>"label"}
                                   inner_cols.add fbml_name(user.id,:useyou=>false),{:class=>"name"} 
                                   e[:labels].each do |name,desc|
                                      if desc == nil
                                          desc = name
                                          name = nil                                         
                                      end                                      
                                      inner_cols.add((name ? "#{name}:" : ""),{:class=>"label"})
                                      inner_cols << desc
                                   end
                            }
                            
                    put_fb_user_default_links(user,links) if options[:default_links] 
                    e[:actions].each do |a_name,a_url,a_options|
                          links.push(fb_link_to(a_name,a_url,options))                    
                    end
                    cols.push links.join("")
                    
                }  
            content_tag(:div,user_table,:class=>"friendtable")
    
    end
    def fb_search_tag html_options={},options={}                
        input_fields = text_field_tag(options.delete(:name) || "q",options.delete(:value),:size=>options[:size],
        :class=>"inputtext inputsearch",:onkeydown=>'if (event.keyCode == 13){this.getForm().submit();return false;}')
        html_options.each do |k,v|
            input_fields << content_tag(:input,"",:type=>"hidden",:name=>k,:value=>v)
        end  
        return  input_fields        
    end
    def fb_search_form url,html_options={},options={},&block        
        form_id = options.delete(:form_id) || rand(10000)
        form_start = form_tag(fb_url_for(url),{:onsubmit=>options[:onsubmit] || "",:id=>form_id,:style=>"display:inline",:method=>'GET'})
        form_end = "</form>" + javascript_tag("submitCleanForm('#{form_id}','#{fb_url_for(url)}')")
        html = fb_search_tag(html_options,options)
        if block_given?            
            html = capture(html,&block)            
            concat(form_start + html + form_end,block.binding)                        
        else
            return    form_start + html + form_end    
        end               
    end

    #createa contextual dialog 
    #parameters title,text and button with a javascript code to be passed to the onclick event attribute of the button
    #or and array of submit buttons with a url to submit the form
    def fb_context_dialog trigger_name,options={}
      if trigger_name.is_a?(Hash)
        options = trigger_name
        trigger_name = nil        
      end
      #the id of the context dialog
      dialog_id = "RAND" + rand(1000000).to_s
      @dialog_id = dialog_id 
      #title and the text of the file
      title = options.delete(:title) || ""
      text = (options.delete(:text) + ".") rescue nil
      control_buttons = ""
      js_hide = "$('#{dialog_id}').style.display='none'"
      js_show = "$('#{dialog_id}').style.display='block'"

      if options[:submits]
          #must submit a form on submit click 
         [options[:submits]].flatten.each do |button_name|
            control_buttons << content_tag(:input,'',:type=>'submit',:class=>'inputsubmit',:name=>'commit',:value=>button_name)
         end 
      else
        options.each do |name,on_click|
            on_click += ";" + js_hide
            control_buttons << <<-eof 
              <input class="inputbutton" onclick="#{on_click}" type="button" value="#{name.to_s.titlecase}">
            eof
        end      
      end   
       control_buttons << <<-eof
           <input class="inputbutton" onclick="#{js_hide}" type="button" value="Cancel">
       eof
      (options[:with] || {}).each do |k,v|
          control_buttons << hidden_field_tag(k,v)
      end
      html = <<-eof 
        <div id="#{dialog_id}" class="fb_contextual_dialog" style="display:none;"> 
            <div class="fb_contextual_arrow" style="background-image: url('#{url_for_app_asset('/images/dialog_triangle.gif')}')"><span >:)</span></div>
            <div class="fb_contextual_dialog_content" >
              <h2 ><span>#{title}</span></h2>
              <div>#{text}</div>
              #{form_tag options[:url]}
                  #{control_buttons}
              </form>
            </div>
        </div>      
     eof
     if trigger_name 
       html += link_to_function(trigger_name,js_show,:id=>"#{dialog_id}a")
     end
     html 
    end
    def fb_paginator paginator,html_options={}
       return if paginator.page_count == 1
       html = pagination_links_each(paginator,{:window_size=>1,:always_show_anchors=>false,:link_to_current_page=>true}) { |page_number|
         options = paginator.current.number == page_number ? {:class=>"current"} : {}         
         content_tag(:li,fb_link_to(page_number,construct_page_url(html_options,page_number)),options)
       }
       if paginator.current.previous
         html = content_tag(:li,fb_link_to("Prev",construct_page_url(html_options,paginator.current.previous.number))) + html 
       end
       if paginator.current.next           
         html << content_tag(:li,fb_link_to("Next",construct_page_url(html_options,paginator.current.next.number)))
       end
       content_tag(:ul,html,:class=>"pagerpro")
    end
    def construct_page_url html_options,page
        if html_options.is_a?(Hash)
          html_options.update(:page=>page)
        else
          html_options += "&page=#{page}"
        end
    end
 
    def fb_actions 
      actions = []
      yield(actions)
      actions.map!{|name,url,options| 
        content_tag(:li,fb_link_to(name,url,options))
      }
      content_tag(:ul,actions.join(""),:class=>"actionspro")      
    end
    def fb_pipe
      '<span class="pipe">|</span>'    
    end


    def fb_plugin_dashboad 
      elements = {:title=> [],:actions=> [],:help=>[],:button=>[]}
      yield(elements)
      actions = elements.delete(:actions)
      help = elements.delete(:help)
      title = elements.delete(:title)
      button = elements.delete(:button)
      unless help.empty? and actions.empty?
        actions = content_tag(:div,actions.map{|a_name,a_link| fb_link_to a_name,a_link }.join(fb_pipe),:class=>"dh_actions")
        help_name,help_url = help.shift
        help = content_tag(:div,fb_link_to(help_name.titlecase,help_url),:class=>"dh_help") rescue ""      
        inside = "<div class='dh_links clearfix'>#{actions + help}</div>"
      else
        inside = ""
      end
      if !title.empty? or !button.empty?
        title,title_img = title.shift;
        title = content_tag(:h2,title); 
        button_name,button_url = button.shift
       
        if button_name && button_url
          button_tag = <<-eof
                <div class="dh_new_media_shell"><a href="#{fb_url_for(button_url || "")}" class="dh_new_media"><div class="tr"><div class="bl"><div class="br">
                  <span>#{button_name}</span>
                </div></div></div></a></div>               
          eof
        else
           button_tag = "" 
        end
        inside += <<-eof
              <div class="dh_titlebar clearfix">
                #{title}
                #{button_tag}
              </div>
        eof
      else
        inside += "<br>"
      end
      content_tag(:div,inside,:class=>"dashboard_header")
    end
    
    def fb_box_subhead title,options={},&block
      
      title_other_classes = options.delete(:other_classes) || ""
      if action_name = options.delete(:action_name)       
        action_url = options.delete(:url) || ""
        html_options = options.delete(:html) || {}       
      end
      html = content_tag(:div,content_tag(:h3,title,:style=>"margin-left:0"),:class=>"box_subtitle #{title_other_classes}")
      if action_name
        html << content_tag(:div,fb_link_to(action_name,action_url,html_options),:class=>"box_actions")
      end
      if block_given? 
        concat fb_css("box") + content_tag(:div,html,:class=>"box_subhead clearfix") + 
               content_tag(:div,capture(&block),:class=>"activitybox"),
               block.binding
      else
        fb_css("box") + content_tag(:div,html,:class=>"box_subhead clearfix")      
      end
    end
    def fb_box_fallback id,text="",&block
        text = block_given? ? capture(&block) : text         
        text = parse_styles("##{id} {padding:0px !important;}") + content_tag(:div,text,:class=>"box_fallback")
        block_given? ? concat(text,block.binding) : text
    end
    def fb_box title=nil,label=nil,&block      
      block_title = []
      block_label = []
      actions = []
      id = 'b' + rand(10000).to_s      
      if !title && !label
        block_content = capture(block_title,block_label,actions,id,&block)
        title = block_title.first
        label = block_label.first
      elsif title && !label
        block_content = capture(block_label,actions,id,&block)
        label = block_label.first
      elsif label && !title
        block_content = capture(block_title,actions,id,&block)
        title = block_title.first
      else   
        block_content = capture(actions,id,&block)
      end
      html = content_tag(:div,content_tag(:h2,title),:class=>"header")
      subheader = ""
      if label
        label = content_tag(:div,label,:class=>"portal_subtitle_info")
        subheader << content_tag(:h3,label)
      end
      if !actions.empty?
        subheader << content_tag(:div,actions.map!{|name,url,options| fb_link_to(name,url,options)}.join(fb_pipe),:class=>"portal_subtitle_action")              
      end
      
      if !subheader.empty?
        html += content_tag(:div,subheader,:class=>"subheader clearfix")
      end
      html += content_tag(:div,block_content,:class=>"box clearfix",:id=>id)
      concat(fb_css("box") + html,block.binding)      
    end  
  end
end