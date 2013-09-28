module AdminHelper
    def link_to_edit(school,options={})
      link_to_function("Edit",<<-eof
                  x = new Ajax();
                  x.responseType=Ajax.FBML;
                  x.ondone = function(response){
                      y = new Dialog(Dialog.DIALOG_POP);
                      y.showChoice("Edit School",response); 
                      y.onconfirm = function(){                                   
                          form_data = document.getElementById("s#{school.id}").serialize();
                          z = new Ajax();
                          z.responseType=Ajax.FBML;
                          z.ondone = function(response) {                        
                              document.getElementById('school_info').setInnerFBML(response);  
                              #{options.delete(:after_edit)}
                          };
                          z.post('#{ajax_url :action=>:edit_school}',form_data)                    
                      }
                  };
                  x.post('#{ajax_url :action=>:edit_school,:nid=>school.id}');
             eof
             )    
    end
end