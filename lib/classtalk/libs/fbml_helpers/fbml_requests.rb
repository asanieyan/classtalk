module Facebook::FBMLHelper
    def fbml_request_choice label,url
        options = {}
        options[:label] = label
        options[:url] = fb_url_for(label)
        content_tag("fb:req-choice","",options)
    end
    def fbml_request_form url,options,&block        
        options[:action] = fb_url_for(url)
        concat(content_tag("fb:request-form",capture(&block),options),block.binding)
    end
    def fbml_friend_selector options
        content_tag("fb:multi-friend-selector","",options)
    end
    def fbml_request_submit
        content_tag("fb:request-form-submit")
    end
    
end  