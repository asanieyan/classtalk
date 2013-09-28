/*
*   Imitation of Prototype.js Class.creat 
*   must pass the arguments manually since there is not arugments variable
*
*/

var FBPrototype = {
  Version: '1.0'
}

var Class = {
  create: function() {
    return function(a1,a2,a3,a4,a5,a6) {
      this.initialize.apply(this, [a1,a2,a3,a4,a5,a6]);
    }
  }
}
var Object = Class.create();
Object.extend = function(destination, source) {
  for (var property in source) {
    destination[property] = source[property]
  }
  return destination;
}

var PrimitiveType = {
        toString : function() {
            return this.self.toString();
        }
}
//Since we can't extend primitive type of javascript some helpers for strings
var String = Class.create();
String.prototype = Object.extend(PrimitiveType,{
       initialize  : function(stringVal) {
            this.self = stringVal;
       },
       truncate: function(length, truncation) {
         length = length || 30;
         truncation = truncation === undefined ? '...' : truncation;
         return this.self.length > length ?
           this.self.slice(0, length - truncation.length) + truncation : this.self;
       }
    } 
)
//Since we can't extend primitive type of javascript some helpers for array
var Array = Class.create();
Array.prototype = Object.extend(PrimitiveType,{
       initialize  : function(e) {
            this.self = e;            
       },
       each : function(method) {
            for(i=0;i<this.self.length;i++) { 
                method($(this.self[i]),i)
            }    
      },
      inject: function(memo, iterator) {
        this.each(function(value, index) {
          memo = iterator(memo, value, index);
        });
        return memo;
      },
      size : function() {
        this.self.length
      },
      include: function(pattern) {
        return this.self.indexOf(pattern) > -1;
      }

    }   
)
function $A(enumerable) {
   return new Array(enumerable)
} 
Ajax.prototype.oldPost = Ajax.prototype.post;
Ajax.Server = null
Ajax.prototype = Object.extend(Ajax.prototype,{
                post : function(url,params) {
                    if (url.indexOf('http://') == -1 && Ajax.Server) {
                            url = Ajax.Server + url                            
                    }   
                    if (typeof parmas == 'string')
                        params += "&xhr=true";
                    else
                        params = Object.extend({xhr:true},params || {});
                    this.oldPost(url,params);
                },
                setOptions: function(options) {
                    this.options = {
                      parameters:   '',
                      afterUpdate : function() {
                      
                      },
                      ondone : function() {
                      
                      },
                      onerror :  function() {
                      
                      }
                    }
                    Object.extend(this.options, options || {});
                },
                setResponseType : function(responseType) {
                    self = this
                    self.responseType = responseType
                    return self;
                }
        });
        
Ajax = Object.extend(Ajax,{
        
        Request : Class.create(),
        Updater : Class.create()

})

Ajax.Request.prototype = Object.extend(new Ajax(),{        
        initialize : function(url,responseType,options) {
                
                this.responseType = responseType                
                this.setOptions(options)               
                this.ondone = this.options.ondone
                this.onerror = this.options.onerror
                this.post(url,this.options.parameters)
        }        
})

Ajax.Updater.prototype = Object.extend(new Ajax(),{                
        initialize : function(container,url,responseType,options) {                
                this.container = $(container);
                this.responseType = responseType;                
                this.setOptions(options)  ;             
               
                this.ondone = function(response) {                    
                    if (this.responseType == Ajax.FBML) {
                        this.container.setInnerFBML(response)
                    }else if (this.responseType == Ajax.RAW){
                         this.container.setTextValue(response)
                    }                                  
                    this.options.afterUpdate(response)
                        
                }.bind(this);
                this.onerror = this.options.onerror;
                this.post(url,this.options.parameters);
        }
    }
)

//NOT WORKING FOR NOW MUST FIX IT LATER
var Insertion = {
    Top : Class.create(),
    After : Class.create(),
    Before : Class.create(),
    Bottom : Class.create()
}
Insertion.Top.prototype = {
    initialize : function(element,text) {        
        each($(element).getParentNode().getChildNodes(),function(e){
                if ($(e) == $(element)) {
                    e = document.createElement("DIV").setTextValue("hey")
                }        
        })
    }
}

var Try = {
  these: function() {
    var returnValue;

    for (var i = 0, length = arguments.length; i < length; i++) {
      var lambda = arguments[i];
      try {
        returnValue = lambda();
        break;
      } catch (e) {}
    }

    return returnValue;
  }
}

function $(element) {
  if (typeof element == 'string')
    element = document.getElementById(element);
  try {
     return Element.extend(element,Element.fbMethods);
  }catch(e){
     return element
  }
}

var Element = {};
Element.extend = function(destination, source) {
  for (var property in source) {
    destination[property] = source[property].bind(destination)
  }
  return destination;
}

Element.fbMethods = {
      visible: function() {
        return this.getStyle('display') != 'none';
      },
      toggle: function() {
        this.visible() ? this.hide() : this.show();
      },
      hide : function() {
        this.setStyle('display','none');        
      },
      show: function() {
        this.setStyle('display',''); 
      },
      update : function(text) {
        this.setTextValue(text)
      },
      observe : function(event,callback) {
        this.addEventListener(event,callback.bind(this))
      }       
}

var Form = {
 getElements : function(form) {
      tags = $A(['input','textarea','select'])
      formElements =  $A(form.getElementsByTagName('*')).inject([],function(elements,child){                
                tagname = child.getTagName().toLowerCase()
                if(tags.include(tagname)) {
                    elements.push($(child))
                }
                return elements
       }) 
       return  $A(formElements)
  },

  serialize: function(form, getHash) {
      if (getHash)
        return form.serialize();
      else {
          x = []
          for (i in form.serialize()) {
            k = i;v = form.serialize()[i];
            if (typeof(v) == "string")
                x.push(k+"="+v)
            else
                for(j in v) {
                    x.push(k+"["+ j +"]"+"="+v[j])
                }
            
          }            
          return x.join("&")
      }
  }
}; 
  


