#These are added features to Rails 1.2.1
#Can be deleted once framework updated to s

#ActiveSupport 
#module ActiveSupport::CoreExtensions::Array::Grouping 
class Array
         def in_groups_of(number, fill_with = nil, &block)          
           require 'enumerator'
           collection = dup
           collection << fill_with until collection.size.modulo(number).zero? unless fill_with == false
           grouped_collection = [] unless block_given?
           collection.each_slice(number) do |group|
             block_given? ? yield(group) : grouped_collection << group
           end
           grouped_collection unless block_given?
         end
end

#ActiveRecord
class ActiveRecord::Associations::AssociationProxy    
    def proxy_owner
      @owner
    end
    def proxy_reflection
      @reflection
    end
    def proxy_target
      @target
    end    
end

#ActionView
module ActionView::Helpers::DateHelper
       def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
         from_time = from_time.to_time if from_time.respond_to?(:to_time)
         to_time = to_time.to_time if to_time.respond_to?(:to_time)
         distance_in_minutes = (((to_time - from_time).abs)/60).round
         distance_in_seconds = ((to_time - from_time).abs).round
 
         case distance_in_minutes
           when 0..1
             return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
             case distance_in_seconds
               when 0..4   then 'less than 5 seconds'
               when 5..9   then 'less than 10 seconds'
               when 10..19 then 'less than 20 seconds'
               when 20..39 then 'half a minute'
               when 40..59 then 'less than a minute'
               else             '1 minute'
             end
 
           when 2..44           then "#{distance_in_minutes} minutes"
           when 45..89          then 'about 1 hour'
           when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
           when 1440..2879      then '1 day'
           when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
           when 43200..86399    then 'about 1 month'
           when 86400..525959   then "#{(distance_in_minutes / 43200).round} months"
           when 525960..1051919 then 'about 1 year'
           else                      "over #{(distance_in_minutes / 525960).round} years"
         end
       end  
end
module ActionView::Helpers::UrlHelper
       def button_to(name, options = {}, html_options = {})
         html_options = html_options.stringify_keys
         convert_boolean_attributes!(html_options, %w( disabled ))
 
         method_tag = ''
         if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
           method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
         end
 
         form_method = method.to_s == 'get' ? 'get' : 'post'
 
         if confirm = html_options.delete("confirm")
           html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
         end
 
         url = options.is_a?(String) ? options : self.url_for(options)
         name ||= url
 
         html_options.merge!("type" => "submit", "value" => name)
 
         "<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button-to\"><div>" +
           method_tag + tag("input", html_options) + "</div></form>"
       end


end
module ActionView::Helpers::JavaScriptHelper    
    def button_to_function(name, *args, &block)
         html_options = args.last.is_a?(Hash) ? args.pop : {}
         function = args[0] || ''
 
         html_options.symbolize_keys!
         function = update_page(&block) if block_given?
         tag(:input, html_options.merge({ 
           :type => "button", :value => name, 
           :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function};" 
         }))
    end
end
module ActionView::Helpers::TagHelper
    def escape_once(html)
      fix_double_escape(html_escape(html.to_s))
    end
    private 
    def  fix_double_escape(escaped)
        escaped.gsub(/&amp;([a-z]+|(#\d+));/i) { "&#{$1};" }
    end
end
module ActionView::Helpers::FormTagHelper
       def form_tag(url_for_options = {}, options = {}, *parameters_for_url, &block)
         html_options = options.stringify_keys
         html_options["enctype"] = "multipart/form-data" if html_options.delete("multipart")
         html_options["action"]  = url_for(url_for_options, *parameters_for_url)
 
         method_tag = ""
         
         case method = html_options.delete("method").to_s
           when /^get$/i # must be case-insentive, but can't use downcase as might be nil
             html_options["method"] = "get"
           when /^post$/i, "", nil
             html_options["method"] = "post"
           else
             html_options["method"] = "post"
             method_tag = content_tag(:div, tag(:input, :type => "hidden", :name => "_method", :value => method), :style => 'margin:0;padding:0')
         end
         
         if block_given?
           content = capture(&block)
           concat(tag(:form, html_options, true) + method_tag, block.binding)
           concat(content, block.binding)
           concat("</form>", block.binding)
         else
           tag(:form, html_options, true) + method_tag
         end
       end    
end
