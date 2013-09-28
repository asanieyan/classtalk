module ClassesHelper
    require 'uri'
    def check_box_filters name,options={}
      options = {:inline=>false}.update(options)
      checkboxes = ""        
      
      controller.class::ParamAttributeMap[name].each_with_index do |label,value|
          label = label[1..label.size-2] 
          uri = request.request_uri.gsub(/%5B/,'[').gsub(/%5D/,']')
          uri = URI::decode(request.request_uri)
          
          checked = uri.match(/#{name}\[\d\]=#{value}/) ? "checked='true'" : ""
          checkbox = <<-eof
                <input type="checkbox" value=#{value} #{checked} name="#{name}[]" id="#{name}_#{value}" class="inputcheckbox"/>
                <label id="label_#{name}_#{value}" for="#{name}_#{value}" style="cursor: default;">#{label}</label>

          eof
          checkboxes += options[:inline] ? checkbox : content_tag(:div,checkbox,:class=>"checkbox")       
      end      
      return options[:inline] ? content_tag(:div,checkboxes,:class=>"checkbox") : checkboxes
    end
end