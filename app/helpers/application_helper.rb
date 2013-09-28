module ApplicationHelper
    def paginator_summary label,paginator
        label = label.to_s
        if paginator.item_count == 0
            ""
        elsif paginator.item_count == 1
           "Displaying the only #{label}"
        elsif paginator.page_count == 1
           "Displaying all #{paginator.item_count} of #{label.pluralize}"
        else
           "Displaying #{paginator.current_page.first_item} - #{paginator.current_page.last_item} out of #{paginator.item_count} #{label.pluralize}"
        end
        
    end
    def inline_progress_bar options={}
        id = options.delete(:id) || "progress_bar"
        text = options.delete(:text)
        text = "&nbsp;&nbsp;&nbsp;" + text if text
        content_tag(:span,image_tag(url_for_app_asset('/images/progress.gif')) + text.to_s,:style=>"display:none;padding-right:10px;padding-left:10px;",:id=>id)
    end
    def url_for_klass klass,options={}
        fb_url_for({:controller=>'classes',:action=>"main",:k=>klass.id}.update(options))
    end
    def link_to_class klass,options={}
        options[:id] ||= "k#{klass.id}"
        full_name = options.delete(:full_name)
#        puts full_name
        full_name = true if full_name.nil?
        name = full_name ? klass.full_title : klass.name
        link_to name,url_for_klass(klass),options        
    end
    def link_to_school school,options={}
        link_to options.delete(:name) || school.name,"http://sfu.facebook.com/networks?nk=#{school.id}",options
    end
    def link_to_report reportable,options={}
        name = options.delete(:name) || "Report"        
#        require 'uri'
#        URI::encode(encrypt(reportable.class)
#        
        fb_link_to name,"/report?t=#{reportable.class.to_s.downcase}&id=#{reportable.id}"
    end
    def link_out_iframe name,options={},html_options={}
        link_to name,"#",html_options.update(:onclick=>"window.parent.url='#{url_for(options)}';return false;")
    end
    
    def generate_chat_topic key=1000
      require 'digest/md5'
      token = ("classtalk" + key.to_s + Time.now.to_date.to_s)       
      Digest::MD5.hexdigest(token)
    end
    def link_to_tos name="Term of Use"
        fb_link_to name,"/help/tos"
    end
    def fb_link_to_network name,nid
      link_to name,"http://www.facebook.com/networks/?nk=#{nid}"
    end
    def fb_message_url uid,subject="",message=""
      "http://www.facebook.com/message.php?id=#{uid}&subject=#{subject}&msg=#{message}"
    end
    def fb_link_send_message uid,subject="",message=""
        link_to "Send Message",fb_message_url(uid,subject,message)
    end
    def fb_poke_url uid
      "http://www.facebook.com/poke.php?id=#{uid}"
    end
    def fb_link_poke uid,name
      link_to name,uid
    end
    def fb_link_add_friend uid,name="Add to Friends"
      link_to name,"http://www.facebook.com/addfriend.php?id=#{uid}"
    end

    def fb_link_see_friends uid,name="View Friends"
      link_to name,"http://www.facebook.com/friends.php?id=#{uid}"
    end
    def fb_link_remove_friend uid,name="Remove Friend"
      link_to name,"http://www.facebook.com/friends.php?remove_friend=1&friend_id=#{uid}"
    end
    def fb_profile_url uid
        "http://www.facebook.com/profile.php?id=#{uid}"
    end
    def fb_link_profile name,uid        
        link_to name,fb_profile_url(uid)
    end
    def fb_default_pic size="t"
        image_tag("http://static.ak.facebook.com//pics/#{size}_default.jpg")
    end
    
    def link_to_help name =nil,options={}
      fb_link_to name || "Help", url_for_help(options.delete(:backurl))
    end
    
    def url_for_help backurl=request.request_uri
      fb_url_for(:controller => 'help', :action => 'main', :backurl => request.request_uri)
    end
    
end