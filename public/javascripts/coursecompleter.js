CourseCompleter = Class.create();
Object.extend(Object.extend(CourseCompleter.prototype, Ajax.Autocompleter.prototype), {
  initialize: function(element, update,controller,options) {
    this.baseInitialize(element, update, options);
    this.options.asynchronous  = true;
    this.options.onComplete    = this.onComplete.bind(this);    
    this.options.defaultParams = this.options.parameters || null;
    this.caller = this.options.caller
    this.controller = controller
    this.url                   = '/' + controller + '/suggest_course'
  },
  getUpdatedChoices: function() {
  
    entry = encodeURIComponent(this.options.paramName) + '=' + 
      encodeURIComponent(this.getToken());
  
    this.options.parameters = this.options.callback ?
      this.options.callback(this.element, entry) : entry;
   
    if(this.options.defaultParams) 
      this.options.parameters += '&' + this.options.defaultParams;
      Object.extend(this.options,{
                    onCreate   : function(r) {
                                 $("pg1").show();
                    },
                    onSuccess : function(r){
                                  $("pg1").hide()
                    }
            });    
    new Ajax.Request(this.url, this.options);
  },  
  afterUpdateElement : function(element,selectedElement){      

    cid = selectedElement.readAttribute("cid") || 0     
    updateURL = '/' + this.controller + "/select_the_course?caller="+ this.options.caller +"&c=" + cid            
    
    new Ajax.Updater('typeahead_select',updateURL,this.options)
  }, 
  onComplete: function(request) { 
    try{
       this.options.afterUpdateElement = this.afterUpdateElement.bind(this)                     
       try{
        thecourses = request.responseText.evalJSON();        
       }catch(e){
        return
       }
       if (thecourses.length == 0) {           
           this.update.innerHTML = "<div class='typeahead_message'>No Match Found </div>"                  
           this.update.style.display = ''
           return
       }
       courseList = "<ul style='style-list:none;padding:0;margin:0'>"       
       thecourses.each(function(c){
            cname = c["name"].gsub(/\{/,'<em>').gsub(/\}/,'</em>')
            courseList += "<li class='typeahead_suggestion' cid='" + c["id"] + "'>" + cname + "</li>"
       })
       courseList += "</ul>"
       
       this.updateChoices(courseList);
    }catch(e){alert(e.message)}
  }

});