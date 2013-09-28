var MessageDisplayer = Class.create()
MessageDisplayer.prototype = {
    initialize : function(msgType,options) {
         options['type'] = msgType
         options['msgs'] = options['msgs'] || ""
         options['list'] = options['list'] || false
         options['hide'] = options['hide'] || true
         if (typeof options['msgs'] == 'string')
             options['msgs'] = [options['msgs']]
         options['msgs'] = options['msgs'].join("####")
         new Ajax.Updater('server_message',MessageDisplayer.server,Ajax.FBML,{
                parameters : options,
                afterUpdate : function(response) {
                       if (options.hide == true)
                           setTimeout(function(){$('server_message').setTextValue('')},3000)
                    }                                
                })         
    }
}

//some helper functions
function showErrorMessage(title,m1,list,hide) {
   
    new MessageDisplayer('error',{'title':title,'msgs':m1 ,'list' : list ,'hide' : hide}) 
}
function showStatusMessage(title,m1,list,hide) {
    new MessageDisplayer('success',{'title':title,'msgs':m1 ,'list' : list ,'hide' : hide})
  
}
function showExplainMessage(title,m1,list,hide) {
    new MessageDisplayer('explanation',{'title':title,'msgs':m1,'list' : list})
  
}

//some dialoge helper
function alert(message,title) {
	try{
	    if (typeof(message) != 'string')
	        message = message.toString();   
		new Dialog(Dialog.DIALOG_POP).showMessage(title || "",message)
	}catch(e){}
}
//some helper functions 
function fitText(textarea,size) {
     if ((value = $(textarea).getValue()).length > size)  {            
            $(textarea).setValue(new String(value).truncate(size,""))        
     }
}
function submitCleanForm(form,url) {   
   $(form).submit = function() {      
      if (url.indexOf('?') == -1) 
        url += "?"      
      document.setLocation(url + "&" + Form.serialize($(form)) )
   }
}
function toggleFiltersSet(array){
     for(i=0;i<array.length;i++){       
        toggle_filterset(array[i],true);
     }
}
function toggle_filterset(element,dontsend) {
    $(element).toggleClassName('collapsed')
        try{
        legend = $(element + "_legend")       
        if ($(element).hasClassName('collapsed')){                                      
            legend.setStyle('background','url('+AppAssets+'/images/filterset_off.gif) 4px 6px no-repeat')
            close = true;
        }
        else {
            legend.setStyle("background","url("+AppAssets+"/images/filterset_on.gif) 4px 6px no-repeat")
            close = false;
        }
        if (!dontsend){
            key = "filter[" + element + "]" 
            new Ajax.Request('/classes/toggle_filters?' + key + "=" + close,Ajax.RAW)            
        }
    }catch(e){}
}