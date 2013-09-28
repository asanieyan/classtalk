module Facebook
  module MockFBML
    def fb_editor options={},html_options={},&block
      html_options = {:method=>"POST",:width=>100}.update(html_options)
      width = html_options.delete(:width)
      content = <<-eof    
        #{form_tag(options,html_options)}
            <table class="editorkit" border="0" cellspacing="0" style="width:450px">
                <tr class="width_setter">
                    <th style="width:#{width}px">
                    </th>
                    <th>
                    </th>
                </tr>
                #{capture(&block)}
            </table>        
        </form>
        <fb:editor action="?commit=yes" labelwidth="100" enctype="multipart/form-data">
        </fb:editor>
      eof
      concat(content,block.binding)
    end

    def fb_editor_text_field name,value="",options={}
          fb_editor_row_wrapper :label=>options.delete(:label),
                                :required=>options.delete(:required),
                                :content=>text_field_tag(name,value,options)

    end
    def fb_editor_text_area name,value="",options={}
         fb_editor_row_wrapper :label=>options.delete(:label),
                               :required=>options.delete(:required),
                               :content=>text_area_tag(name,value,options)
    end
    def fb_editor_hidden_field name,value=""
        fb_editor_row_wrapper :lable=>"",:content=>hidden_field_tag(name,value)
    end
    def fb_editor_field label,value
         fb_editor_row_wrapper :label=>label,                               
                               :content=>value    
    end    
    def fb_editor_costum_tag label="",options={},&block
         concat(fb_editor_row_wrapper(:label=>label,
                               :required=>options.delete(:required),
                               :content=>capture(&block)),block.binding)
    end
    alias fb_editor_custom_tag fb_editor_costum_tag
    def fb_editor_divider
        '<tr><th></th><td colspan="2"><div class="divider"></div></td></tr>'
    end
    def fb_editor_buttons 
      buttons={:buttons=>[],:cancel=>[]}
      yield(buttons[:buttons],buttons[:cancel])
      button_set = ""
      buttons[:buttons].each do |submit_button|
            name,options=submit_button.shift,submit_button.shift ||{}
            options = options.update(:class=>"editorkit_button action")
            button_set << submit_tag(name,options)
      end
      cancel_link = buttons[:cancel].first
      if cancel_link
        cancel_link = link_to(cancel_link.shift,cancel_link.shift,cancel_link.shift)
        button_set << '<span class="cancel_link">'
        button_set << "<span>or</span>" unless button_set == ""
        button_set << cancel_link
        button_set << "</span>"
      end
      <<-eof
      <tr id='buttons'><th></th><td class="editorkit_buttonset">
          #{button_set}
      </td><td class="right_padding"></td></tr>      
      eof
    end
  private
    
    def fb_editor_row_wrapper options={}
      detached_label = options[:detached_label] ? "detached_label" : ""
      label = options[:label].to_s.size > 0 ? content_tag(:label,options.delete(:label) + ":") : nil
      if options[:required] == true
          req = "(required)"
      elsif options[:required]
          req = "(#{options[:required]})"
      end
      label += "<br><small>#{req}</small>" if label && options[:required]

      content = options.delete(:content) 
      <<-eof
        <tr>
          <th class="detached_label">
            #{label}
          </th>
          <td class="editorkit_row">
              #{content}
          </td>
          <td class="right_padding">
          </td>
        </tr>
      eof
    end      
  
  end
end