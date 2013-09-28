/*
 * Some extra dom element utility functions 
 * 
 */
    var MyUtils = {
        /*
         * create an element of the tag and appends it to the element1
         */
		append: function(element1, tag){           
           element2 = document.createElement(tag)          
           $(element1).appendChild(element2)
           return element2
        },
		/*
		 * creates a click event listener that will hide the element if it is not clicked on
		 * when the mouse click event fires
		 * Parameters : elements - you can also pass in an array of elements that if clicked on will not 
		 * 						   cause the element to disapear
		 * 				hideCallback - a callback  function to be called when the element hides
		 */
		hideIfNotClickedOn : function(element,elements,hideCallBack) {
			if (!hideCallBack){
				hideCallBack = function() {
					
				}			
			}
			element = $(element)
			if (!elements || elements.length == 0)
				elements = [element]

			elements = [elements].flatten().map(function(e){
					return $(e)
			})				
			Event.observe(window,'click',function(event){				
				
				if (!elements.include(Event.element(event))){
					$(element).hide()
					hideCallBack.apply()
				}		
			})	
		}		
    } 
    Element.addMethods(MyUtils);    
/*
 * Select element helper methods 
 * 
 */
var Select =  {     
        disable : function(){        
            this.disabled = true;
        },
        enable : function(){
          this.disabled = false;
        },
        eachOption : function(element1,callback) {
           element1 = $(element1)
           for(i=0;i<element1.options.length;i++) {
               try {                                      

                    callback($(element1.options[i]),i)
               }catch(e){
                    
                    if (e != $break) throw e; 
                    else
                        break;              
               }
           }             
        }, 
        clearOptions : function(element1) {
            element1 = $(element1)
            element1.eachOption(function(option){
                    option.selected = false
                    
                
            })            
        },        
        setOptionByValue : function(element1,value){
                element1 = $(element1)
                element1.clearOptions();
                foundIndex = 0
                element1.eachOption(function(option,index){                        
                        if  (option.value == value) {
                            foundIndex = index
                            throw $break;    
                        }
                                                
                }) 
                element1.selectedIndex = foundIndex
        },
        selectedOption : function(element1) {
             element1 = $(element1)
             selectedOption = null
             element1.eachSelectedOption(function(option){
                    
                    selectedOption = option
                    throw $break;             
             })
             return selectedOption
        },
        eachSelectedOption : function(element1,callback) {
              element1 = $(element1)
              element1.eachOption(function(option){
                    
                    if (option.selected == true) {
                        callback(option)
                    }              
              })            
        },
        update : function(element1,text) {
            $(element1).innerHTML = text
        }
}
Element.addMethods(Select)
/*
 * Message class basically handles showing messages to the user
 * Parameters
 * parentContainer : the div or any container the will container the message 
 * msgs: a single or an array of messages to be shown. they each will be placed in a <p> tag
 * options: msgType - determines the type of message. this type will determine the how the message is presented to the user
 * 					- right now the there are two types error and status
 * 			hide 	- if it is set to true it will hide the message after a default number of seconds
 * 					- if set to a number it will hide the message after that number of seconds is passed
 * 	some helper methods are supplied for each different type of message to be shown 	
 */
var Message = Class.create();
Message.prototype = {                 
	 options : {        	 	
		  hide: true,
          block : function() {} 
     }, 
	 initialize : function(parentContainer,msgs,options) {
	 	this.options = Object.extend(this.options,options || {})			
		this.parentContainer = $(parentContainer)		
		msgs = [msgs].flatten();
		
		if (this.parentContainer && msgs.length > 0){
			this.parentContainer.innerHTML = ''
			msgs = msgs.map(function(e){
				return "<p>" + e + "</p>"
			}).join("")
			this.parentContainer.innerHTML = this.placeMessage(this.options.msgType,msgs)
			if (this.options.hide) {
				setTimeout("$('" + this.parentContainer.id + "').innerHTML=''",3000)
			}
		}
	 	
	 },
	 placeMessage : function(msgType,msg) {
	 	switch(msgType) {
			case "error" :
				return "<div class='standard-message'><div id='error'>"+msg +"</div></div>";
			case "status" :
				return "<div class='standard-message'><div class='status'>"+msg+"</div></div>";
			default : 
				return "";
		}			
	}	 
}
/*
 * helper methods for the message class 
 */
function showErrorMessage(container,message) {
	return new Message(container,message,{msgType:"error",hide:false})
}
function showErrorMessageAndHide(container,message) {
	return new Message(container,message,{msgType:"error",hide:true})
}
function showStatusMessage(container,message) {
	return new Message(container,message,{msgType:"status"})
}
function fitText(textarea,size) {
     if ((value = $(textarea).value).length > size)  {            
            $(textarea).value = value.truncate(size,"")
     }
}
/*******these classes and function below only works on top of the facebook javascript lib*********/
function ShowFbAjaxDialog(src) {
	var dialog = new pop_dialog('');
	dialog.show_ajax_dialog(src);
}