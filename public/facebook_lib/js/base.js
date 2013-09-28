/************base.js******/
function ge()
{var ea;for(var i=0;i<arguments.length;i++){var e=arguments[i];if(typeof e=='string')
e=document.getElementById(e);if(arguments.length==1)
return e;if(!ea)
ea=new Array();ea[ea.length]=e;}
return ea;}
function $(){var el=ge.apply(null,arguments);if(!el){Util.warn('Tried to get element %q, but it is not present in the page. (Use ge() '+'to test for the presence of an element.)',arguments[0]);}
return el;}
function show()
{for(var i=0;i<arguments.length;i++){var element=ge(arguments[i]);if(element&&element.style)element.style.display='';}
return false;}
function hide()
{for(var i=0;i<arguments.length;i++){var element=ge(arguments[i]);if(element&&element.style)element.style.display='none';}
return false;}
function shown(el){el=ge(el);return(el.style.display!='none');}
function toggle()
{for(var i=0;i<arguments.length;i++){var element=ge(arguments[i]);element.style.display=(element.style.display=='block'||element.style.display=='')?'none':'block';}
return false;}
function is_descendent(base_obj,target_id){var target_obj=ge(target_id);if(base_obj==null)return;while(base_obj!=target_obj){if(base_obj.parentNode){base_obj=base_obj.parentNode;}else{return false;}}
return true;}
function close_more_list(){var list_expander=ge('expandable_more');if(list_expander){list_expander.style.display='none';removeEventBase(document,'click',list_expander.offclick,list_expander.id);}
var sponsor=ge('ssponsor');if(sponsor){sponsor.style.position='';}
var link_obj=ge('more_link');if(link_obj){link_obj.innerHTML='more';link_obj.className='expand_link more_apps';}}
function expand_more_list(){var ajax_ping=new FBAjax();ajax_ping.onDone=function(ajaxObj,responseText){}
ajax_ping.onFail=function(ajaxObj){}
ajax_ping.post('/ajax/more_click.php');var list_expander=ge('expandable_more');var more_link=ge('more_section');if(more_link){remove_css_class_name(more_link,'highlight_more_link');}
if(list_expander){list_expander.style.display='block';list_expander.offclick=function(e){if(!is_descendent(e.target,'sidebar_content')){close_more_list();}}.bind(list_expander);addEventBase(document,'click',list_expander.offclick,list_expander.id);}
var sponsor=ge('ssponsor');if(sponsor){sponsor.style.position='static';}
var link_obj=ge('more_link');if(link_obj){link_obj.innerHTML='less';link_obj.className='expand_link less_apps';}}
function toggle_more_list(){var list_expander=ge('expandable_more');var ajax_ping=new FBAjax();ajax_ping.onDone=function(ajaxObj,responseText){}
ajax_ping.onFail=function(ajaxObj){}
ajax_ping.post('/ajax/more_click.php');if(!list_expander){return false;}
if(list_expander.style.display=='none'){expand_more_list();}else{close_more_list();}}
function remove_node(node)
{if(node.removeNode)
node.removeNode(true);else{for(var i=node.childNodes.length-1;i>=0;i--)
remove_node(node.childNodes[i]);node.parentNode.removeChild(node);}
return null;}
function create_hidden_input(name,value){var new_input=document.createElement('input');new_input.name=name;new_input.value=value;new_input.type='hidden';return new_input;}
function has_css_class_name(elem,cname){return(elem&&cname)?new RegExp('\\b'+trim(cname)+'\\b').test(elem.className):false;}
function add_css_class_name(elem,cname){if(elem&&cname){if(elem.className){if(has_css_class_name(elem,cname)){return false;}else{elem.className+=' '+trim(cname);return true;}}else{elem.className=cname;return true;}}else{return false;}}
function remove_css_class_name(elem,cname){if(elem&&cname&&elem.className){cname=trim(cname);var old=elem.className;elem.className=elem.className.replace(new RegExp('\\b'+cname+'\\b'),'');return elem.className!=old;}else{return false;}}
function set_inner_html(obj,html){obj.innerHTML=html;var scripts=obj.getElementsByTagName('script');for(var i=0;i<scripts.length;i++){if(scripts[i].src){var script=document.createElement('script');script.type='text/javascript';script.src=scripts[i].src;document.body.appendChild(script);}else{try{eval(scripts[i].innerHTML);}catch(e){if(typeof console!='undefined'){console.error(e);}}}}}
var KEYS={BACKSPACE:8,TAB:9,RETURN:13,ESC:27,SPACE:32,LEFT:37,UP:38,RIGHT:39,DOWN:40,DELETE:46};function mouseX(event)
{return event.pageX||(event.clientX+
(document.documentElement.scrollLeft||document.body.scrollLeft));}
function mouseY(event)
{return event.pageY||(event.clientY+
(document.documentElement.scrollTop||document.body.scrollTop));}
function pageScrollX()
{return document.body.scrollLeft||document.documentElement.scrollLeft;}
function pageScrollY()
{return document.body.scrollTop||document.documentElement.scrollTop;}
function elementX(obj)
{var curleft=0;if(obj.offsetParent){while(obj.offsetParent){curleft+=obj.offsetLeft;obj=obj.offsetParent;}}
else if(obj.x)
curleft+=obj.x;return curleft;}
function elementY(obj)
{var curtop=0;if(obj.offsetParent){while(obj.offsetParent){curtop+=obj.offsetTop;obj=obj.offsetParent;}}
else if(obj.y)
curtop+=obj.y;return curtop;}
function onloadRegister(handler){if(window.onload){var old=window.onload;window.onload=function(){old();handler();};}
else{window.onload=handler;}}
function onbeforeunloadRegister(handler){if(window.onbeforeunload){var old=window.onbeforeunload;window.onbeforeunload=function(){var ret=old();if(ret){return ret;}
return handler();};}
else{window.onbeforeunload=handler;}}
function warn_if_unsaved(form_id){onloadRegister(function(){var form_state=[];var form=ge(form_id);var inputs=get_all_form_inputs(form);for(var i=0;i<inputs.length;++i){if(is_button(inputs[i])){inputs[i].onclick=bind(null,function(old,e){document.unsaved_warning_disabled=true;return old&&old(e);},inputs[i].onclick);}else if(is_descendent(inputs[i],form)){form_state.push({'element':inputs[i],'value':inputs[i].value});}}
(function(original_form_state){onbeforeunloadRegister(function(){if(!document.unsaved_warning_disabled){for(var i=0;i<original_form_state.length;++i){var input_element=original_form_state[i].element;var original_value=original_form_state[i].value;if(input_element.value!=original_value){return'You have unsaved changes.  Continue?'}}}});})(form_state);});}
function get_all_form_inputs(){var ret=[];var tag_names={'input':1,'select':1,'textarea':1,'button':1};for(var tag_name in tag_names){var elements=document.getElementsByTagName(tag_name);for(var i=0;i<elements.length;++i){ret.push(elements[i]);}}
return ret;}
function is_button(element){var tagName=element.tagName.toUpperCase();if(tagName=='BUTTON'){return true;}
if(tagName=='INPUT'&&element.type){var type=element.type.toUpperCase();return type=='BUTTON'||type=='SUBMIT';}
return false;}
function addEventBase(obj,type,fn,name_hash)
{if(obj.addEventListener)
obj.addEventListener(type,fn,false);else if(obj.attachEvent)
{obj["e"+type+fn+name_hash]=fn;obj[type+fn+name_hash]=function(){obj["e"+type+fn+name_hash](window.event);}
obj.attachEvent("on"+type,obj[type+fn+name_hash]);}}
function removeEventBase(obj,type,fn,name_hash)
{if(obj.removeEventListener)
obj.removeEventListener(type,fn,false);else if(obj.detachEvent)
{obj.detachEvent("on"+type,obj[type+fn+name_hash]);obj[type+fn+name_hash]=null;obj["e"+type+fn+name_hash]=null;}}
function placeholderSetup(id){var el=ge(id);if(!el)return;var ph=el.getAttribute("placeholder");if(ph&&ph!=""){el.value=ph;el.style.color='#777';el.is_focused=0;addEventBase(el,'focus',placeholderFocus);addEventBase(el,'blur',placeholderBlur);}}
function placeholderFocus(){if(!this.is_focused){this.is_focused=1;this.value='';this.style.color='#000';var rs=this.getAttribute("radioselect");if(rs&&rs!=""){var re=document.getElementById(rs);if(!re){return;}
if(re.type!='radio')return;re.checked=true;}}}
function placeholderBlur(){var ph=this.getAttribute("placeholder")
if(this.is_focused&&ph&&this.value==""){this.is_focused=0;this.value=ph;this.style.color='#777';}}
function optional_drop_down_menu(arrow,link,menu,event,arrow_class,arrow_old_class)
{if(menu.style.display=='none'){menu.style.display='block';var old_arrow_classname=arrow_old_class?arrow_old_class:arrow.className;if(link){link.className='active';}
arrow.className=arrow_class?arrow_class:'global_menu_arrow_active';var justChanged=true;var shim=ge(menu.id+'_iframe');if(shim){shim.style.top=menu.style.top;shim.style.right=menu.style.right;shim.style.display='block';shim.style.width=(menu.offsetWidth+2)+'px';shim.style.height=(menu.offsetHeight+2)+'px';}
menu.offclick=function(e){if(!justChanged){hide(this);if(link){link.className='';}
arrow.className=old_arrow_classname;var shim=ge(menu.id+'_iframe');if(shim){shim.style.display='none';shim.style.width=menu.offsetWidth+'px';shim.style.height=menu.offsetHeight+'px';}
removeEventBase(document,'click',this.offclick,menu.id);}else{justChanged=false;}}.bind(menu);addEventBase(document,'click',menu.offclick,menu.id);}
return false;}
function position_app_switcher(){var switcher=ge('app_switcher');var menu=ge('app_switcher_menu');menu.style.top=(switcher.offsetHeight-1)+'px';menu.style.right='0px';}
function escapeURI(u)
{if(encodeURIComponent){return encodeURIComponent(u);}
if(escape){return escape(u);}}
function goURI(href){window.location.href=href;}
function is_email(email){return/^[\w!.%+]+@[\w]+(?:\.[\w]+)+$/.test(email);}
function getViewportWidth(){var width=0;if(document.documentElement&&document.documentElement.clientWidth){width=document.documentElement.clientWidth;}
else if(document.body&&document.body.clientWidth){width=document.body.clientWidth;}
else if(window.innerWidth){width=window.innerWidth-18;}
return width;};function getViewportHeight(){var height=0;if(window.innerHeight){height=window.innerHeight-18;}
else if(document.documentElement&&document.documentElement.clientHeight){height=document.documentElement.clientHeight;}
else if(document.body&&document.body.clientHeight){height=document.body.clientHeight;}
return height;};function getPageScrollHeight(){var height;if(typeof(window.pageYOffset)=='number'){height=window.pageYOffset;}else if(document.body&&document.body.scrollTop){height=document.body.scrollTop;}else if(document.documentElement&&document.documentElement.scrollTop){height=document.documentElement.scrollTop;}
return height;};function getRadioFormValue(obj){for(i=0;i<obj.length;i++){if(obj[i].checked){return obj[i].value;}}
return null;}
function getTableRowShownDisplayProperty(){if(ua.ie()){return'inline';}else{return'table-row';}}
function showTableRow()
{for(var i=0;i<arguments.length;i++){var element=ge(arguments[i]);if(element&&element.style)element.style.display=getTableRowShownDisplayProperty();}
return false;}
function getParentRow(el){el=ge(el);while(el.tagName&&el.tagName!="TR"){el=el.parentNode;}
return el;}
function stopPropagation(e){if(!e)var e=window.event;e.cancelBubble=true;if(e.stopPropagation){e.stopPropagation();}}
function show_standard_status(status){s=ge('standard_status');if(s){var header=s.firstChild;header.innerHTML=status;show('standard_status');}}
function hide_standard_status(){s=ge('standard_status');if(s){hide('standard_status');}}
function remove_node(node){if(node.removeNode)
node.removeNode(true);else{for(var i=node.childNodes.length-1;i>=0;i--)
remove_node(node.childNodes[i]);node.parentNode.removeChild(node);}
return null;}
function adjustImage(obj,stop_word,max){var pn=obj.parentNode;if(stop_word==null)
stop_word='note_content';if(max==null){while(pn.className.indexOf(stop_word)==-1)
pn=pn.parentNode;if(pn.offsetWidth)
max=pn.offsetWidth;else
max=400;}
if(navigator.userAgent.indexOf('AppleWebKit/4')==-1){obj.style.position='absolute';obj.style.left=obj.style.top='-32000px';}
obj.className=obj.className.replace('img_loading','img_ready');if(obj.width>max){if(window.ActiveXObject){try{var img_div=document.createElement('div');img_div.style.filter='progid:DXImageTransform.Microsoft.AlphaImageLoader(src="'+obj.src.replace('"','%22')+'", sizingMethod="scale")';img_div.style.width=max+'px';img_div.style.height=((max/obj.width)*obj.height)+'px';if(obj.parentNode.tagName=='A')
img_div.style.cursor='pointer';obj.parentNode.insertBefore(img_div,obj);obj.removeNode(true);}
catch(e){obj.style.width=max+'px';}}
else
obj.style.width=max+'px';}
obj.style.left=obj.style.top=obj.style.position='';}
function imageConstrainSize(src,maxX,maxY,placeholderid){var image=new Image();image.onload=function(){if(image.width>0&&image.height>0){var width=image.width;var height=image.height;if(width>maxX||height>maxY){var desired_ratio=maxY/maxX;var actual_ratio=height/width;if(actual_ratio>desired_ratio){width=width*(maxY/height);height=maxY;}else{height=height*(maxX/width);width=maxX;}}
var placeholder=ge(placeholderid);var newimage=document.createElement('img');newimage.src=src;newimage.width=width;newimage.height=height;placeholder.parentNode.insertBefore(newimage,placeholder);placeholder.parentNode.removeChild(placeholder);}}
image.src=src;}
function set_opacity(obj,opacity){try{obj.style.opacity=(opacity==1?'':opacity);obj.style.filter=(opacity==1?'':'alpha(opacity='+opacity*100+')');}
catch(e){}
obj.setAttribute('opacity',opacity);}
function get_opacity(obj){return obj.opacity?obj.opacity:1;}
function focus_login(){var email=ge("email");var pass=ge("pass");var dologin=ge("doquicklogin");if(email&&pass){if(email.value!=""&&pass.value==""){pass.focus();}else if(email.value==""){email.focus();}else if(email.value!=""&&pass.value!=""){dologin.focus();}}}
function array_indexOf(arr,val,index){if(!index){index=0;}
for(var i=index;i<arr.length;i++){if(arr[i]==val){return i;}}
return-1;}
var ua={populate:function(){var agent=/(?:MSIE.(\d+\.\d+))|(?:Firefox.(\d+\.\d+))|(?:Opera.(\d+\.\d+))|(?:AppleWebKit.(\d+.\d+))/.exec(navigator.userAgent);if(!agent){this._ie=this._firefox=this._opera=this._safari=0;}
this._ie=parseFloat(agent[1]?agent[1]:0);this._firefox=parseFloat(agent[2]?agent[2]:0);this._opera=parseFloat(agent[3]?agent[3]:0);this._safari=parseFloat(agent[4]?agent[4]:0);this.populated=true;},populated:false,ie:function(){if(!this.populated)this.populate();return this._ie;},firefox:function(){if(!this.populated)this.populate();return this._firefox;},opera:function(){if(!this.populated)this.populate();return this._opera;},safari:function(){if(!this.populated)this.populate();return this._safari;},matches:function(str){return(navigator.userAgent.indexOf(str)!=-1);}}
function subclass(sub,parent){sub.prototype=sub.prototype||{};sub.prototype.prototype=parent.prototype;sub.prototype.parent=parent;return sub;}
Function.prototype.extend=function(superclass){var superprototype=__metaprototype(superclass,0);var subprototype=__metaprototype(this,superprototype.prototype.__level+1);subprototype.parent=superprototype;}
function __metaprototype(obj,level){if(obj.__metaprototype){return obj.__metaprototype;}
var metaprototype=new Function();metaprototype.construct=__metaprototype_construct;metaprototype.prototype.construct=__metaprototype_wrap(obj,level);metaprototype.prototype.__level=level;metaprototype.base=obj;obj.prototype.parent=metaprototype;obj.__metaprototype=metaprototype;return metaprototype;}
function __metaprototype_construct(instance){__metaprototype_init(instance.parent);var parents=[];var obj=instance;while(obj.parent){parents.push(new_obj=new obj.parent());new_obj.__instance=instance;obj=obj.parent;}
instance.parent=parents[1];parents.reverse();parents.pop();instance.__parents=parents;instance.__instance=instance;var args=[];for(var i=1;i<arguments.length;i++){args.push(arguments[i]);}
return instance.parent.construct.apply(instance.parent,args);}
function __metaprototype_init(metaprototype){if(metaprototype.initialized)return;var base=metaprototype.base.prototype;if(metaprototype.parent){__metaprototype_init(metaprototype.parent);var parent_prototype=metaprototype.parent.prototype;for(i in parent_prototype){if(i!='__level'&&i!='construct'&&base[i]===undefined){base[i]=metaprototype.prototype[i]=parent_prototype[i]}}}
metaprototype.initialized=true;var level=metaprototype.prototype.__level;for(i in base){if(i!='parent'){base[i]=metaprototype.prototype[i]=__metaprototype_wrap(base[i],level);}}}
function __metaprototype_wrap(method,level){if(typeof method!='function'||method.__prototyped){return method;}
var func=function(){var instance=this.__instance;if(instance){var old_parent=instance.parent;instance.parent=level?instance.__parents[level-1]:null;var ret=method.apply(instance,arguments);instance.parent=old_parent;return ret;}else{return method.apply(this,arguments);}}
func.__prototyped=true;return func;}
function dp(object)
{var descString="";for(var value in object){try{descString+=(value+" => "+object[value]+"\n");}catch(exception){descString+=(value+" => "+exception+"\n");}}
if(descString!="")
alert(descString);else
alert(object);}
function adClick(id)
{ajax=new FBAjax();ajax.get('ajax/redirect.php',{'id':id},true);return true;}
function abTest(data,inline)
{ajax=new FBAjax();ajax.get('/ajax/abtest.php',{'data':data},true);if(!inline){return true;}}
function ajaxArrayToQueryString(query,name){if(typeof query=='object'){var params=[];for(var i in query){params.push(ajaxArrayToQueryString(query[i],name?name+'['+i+']':i));}
return params.join('&');}else{return name?encodeURIComponent(name)+'='+(query!=null?encodeURIComponent(query):''):query;}}
function setCookie(cookieName,cookieValue,nDays){var today=new Date();var expire=new Date();if(nDays==null||nDays==0)nDays=1;expire.setTime(today.getTime()+3600000*24*nDays);document.cookie=cookieName+"="+escape(cookieValue)+"; expires="+expire.toGMTString()+"; path=/; domain=.facebook.com";}
function clearCookie(cookieName){document.cookie=cookieName+"=; expires=Mon, 26 Jul 1997 05:00:00 GMT; path=/; domain=.facebook.com";}
function getCookie(name){var nameEQ=name+"=";var ca=document.cookie.split(';');for(i=0;i<ca.length;i++){var c=ca[i];while(c.charAt(0)==' ')c=c.substring(1,c.length);if(c.indexOf(nameEQ)==0){return unescape(c.substring(nameEQ.length,c.length));}}
return null;}
function do_post(url){var pieces=/(^([^?])+)\??(.*)$/.exec(url);var form=document.createElement('form');form.action=pieces[1];form.method='post';form.style.display='none';var sparam=/([\w]+)(?:=([^&]+)|&|$)/g;var param=null;if(ge('post_form_id'))
pieces[3]+='&post_form_id='+ge('post_form_id').value;while(param=sparam.exec(pieces[3])){var input=document.createElement('input');input.type='hidden';input.name=param[1];input.value=param[2];form.appendChild(input);}
document.body.appendChild(form);form.submit();return false;}
function anchor_set(anchor){window.location=window.location.href.split('#')[0]+'#'+anchor;}
function anchor_get(){return window.location.href.split('#')[1]||null;}
function get_event(e){return e||window.event;}
/*****extended.js******/
function bind(obj,method){obj=obj||window;var args=[];for(var ii=2;ii<arguments.length;ii++){args.push(arguments[ii]);}
return function(){var _args=[];for(var kk=0;kk<args.length;kk++){_args.push(args[kk]);}
for(var jj=0;jj<arguments.length;jj++){_args.push(arguments[jj]);}
if(typeof(method)=="string"){if(obj[method]){return obj[method].apply(obj,_args);}}else{return method.apply(obj,_args);}}}
Function.prototype.bind=function(context){var argv=[arguments[0],this]
var argc=arguments.length;for(var ii=1;ii<argc;ii++){argv.push(arguments[ii]);}
return bind.apply(null,argv);}
function chain(u,v){var calls=[];for(var ii=0;ii<arguments.length;ii++){calls.push(arguments[ii]);}
return function(){for(var ii=0;ii<calls.length;ii++){if(calls[ii]&&calls[ii].apply(null,arguments)===false){return false;}}
return true;}}
function copy_properties(u,v){for(var k in v){u[k]=v[k];}
return u;}
var Try={these:function(){var len=arguments.length;var res;for(var ii=0;ii<len;ii++){try{res=arguments[ii]();return res;}catch(anIgnoredException){}}
return res;}};var Util={isDevelopmentEnvironment:function(){return(typeof(HTTPRequest)!='undefined')&&HTTPRequest.dev;},warn:function(){Util.log(sprintf.apply(null,arguments),'warn');},error:function(){Util.log(sprintf.apply(null,arguments),'error');},log:function(msg,type){if(Util.isDevelopmentEnvironment()){if(typeof(window['infoConsole'])!='undefined'){infoConsole.addEvent(new fbinfoconsole.ConsoleEvent(['js',type],nl2br(msg)));}else{if(type!='deprecated'){alert(msg);}}}else{if(type=='error'){(typeof(window['debug_rlog'])=='function')&&debug_rlog(msg);}}},deprecated:function(what){if(!Util._deprecatedThings[what]){Util._deprecatedThings[what]=true;var msg=sprintf('Deprecated: %q is deprecated.\n\n%s',what,Util.whyIsThisDeprecated(what));Util.log(msg,'deprecated');}},whyIsThisDeprecated:function(what){return Util._deprecatedBecause[what.toLowerCase()]||'No additional information is available about this deprecation.';},_deprecatedBecause:{},_deprecatedThings:{}};var IConfigurable={getOption:function(opt){if(typeof(this.option[opt])=='undefined'){Util.warn('Failed to get option %q; it does not exist.',opt);return null;}
return this.option[opt];},setOption:function(opt,v){if(typeof(this.option[opt])=='undefined'){Util.warn('Failed to set option %q; it does not exist.',opt);}else{this.option[opt]=v;}
return this;},getOptions:function(){return this.option;}};function Ad(){}
copy_properties(Ad,{refreshRate:10000,lastRefreshTime:new Date(),refresh:function(){var delta=(new Date().getTime()-Ad.lastRefreshTime.getTime());if(delta>Ad.refreshRate){var f=Ad.getFrame();if(f){if(!f.osrc){f.osrc=f.src;}
f.src=f.osrc+'?'+Math.random();Ad.lastRefreshTime=new Date();}}},getFrame:function(){return ge('ssponsor')&&ge('ssponsor').getElementsByTagName('iframe')[0];}});
/****string.js****/
function htmlspecialchars(text){if(typeof(text)=='undefined'||!text.toString){return'';}
return text.toString().replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/'/g,'&#039;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function escape_js_quotes(text){if(typeof(text)=='undefined'||!text.toString){return'';}
return text.toString().replace(/\\/g,'\\\\').replace(/\n/g,'\\n').replace(/\r/g,'\\r').replace(/"/g,'\\x22').replace(/'/g,'\\\'').replace(/</g,'\\x3c').replace(/>/g,'\\x3e').replace(/&/g,'\\x26');}
function trim(text){if(typeof(text)=='undefined'||!text.toString){return'';}
return text.toString().replace(/^\s*|\s*$/g,'');}
function nl2br(text){if(typeof(text)=='undefined'||!text.toString){return'';}
return text.toString().replace(/\n/g,'<br />');}
function sprintf(){if(arguments.length==0){Util.warn('sprintf() was called with no arguments; it should be called with at '+'least one argument.');return'';}
var args=['This is an argument vector.'];for(var ii=arguments.length-1;ii>0;ii--){if(typeof(arguments[ii])=="undefined"){Util.log('You passed an undefined argument (argument '+ii+' to sprintf(). '+'Pattern was: `'+(arguments[0])+'\'.','error');args.push('');}else if(arguments[ii]===null){args.push('');}else if(arguments[ii]===true){args.push('true');}else if(arguments[ii]===false){args.push('false');}else{if(!arguments[ii].toString){Util.log('Argument '+(ii+1)+' to sprintf() does not have a toString() '+'method. The pattern was: `'+(arguments[0])+'\'.','error');return'';}
args.push(arguments[ii]);}}
var pattern=arguments[0];pattern=pattern.toString().split('%');var patlen=pattern.length;var result=pattern[0];for(var ii=1;ii<patlen;ii++){if(args.length==0){Util.log('Not enough arguments were provide to sprintf(). The pattern was: '+'`'+(arguments[0])+'\'.','error');return'';}
if(!pattern[ii].length){result+="%";continue;}
switch(pattern[ii].substr(0,1)){case's':result+=htmlspecialchars(args.pop().toString());break;case'h':result+=args.pop().toString();break;case'd':result+=parseInt(args.pop());break;case'f':result+=parseFloat(args.pop());break;case'q':result+="`"+htmlspecialchars(args.pop().toString())+"'";break;case'e':result+="'"+escape_js_quotes(args.pop().toString())+"'";break;case'x':x=args.pop();result+=x.toString()+' [at line '+x.line+' in '+x.sourceURL+']';break;default:result+="%"+pattern[ii].substring(0,1);break;}
result+=pattern[ii].substring(1);}
if(args.length>1){Util.log('Too many arguments ('+(args.length-1)+' extras) were passed to '+'sprintf(). Pattern was: `'+(arguments[0])+'\'.','error');}
return result;}
/******async.js*******/
function AsyncRequest(){var dispatchResponse=bind(this,function(asyncResponse){try{this.handler(asyncResponse);}catch(exception){Util.error('Async handler threw an exception for URI %q: %x.',this.uri,exception);}});var dispatchErrorResponse=bind(this,function(asyncResponse){try{this.errorHandler(asyncResponse);}catch(exception){Util.error('Async error handler threw an exception for URI %q, when processing a '+'%d error: %s.',this.uri,asyncResponse.getError(),exception);}});var invokeResponseHandler=bind(this,function(){var r=new AsyncResponse();if(this.handler){try{if(!this.getOption('suppressEvaluation')){eval('response = ('+this.transport.responseText+')');copy_properties(r,response);}else{r.payload=this.transport;}
if(r.getError()){dispatchErrorResponse(r);}else{dispatchResponse(r);}}catch(exception){var desc='An error occurred during a request to a remote server. '+'This failure may be temporary, try repeating the request.';if(Util.isDevelopmentEnvironment()){desc=sprintf('An error occurred when decoding the JSON payload of the '+'AsyncResponse associated with an AsyncRequest to %q. The server '+'returned <a href="javascript:alert(%e);">a garbled response</a>,'+'then Javascript threw an exception: %x.',this.uri,this.transport.responseText,exception);}
copy_properties(r,{error:-1,errorSummary:'Data Error',errorDescription:desc});if(this.errorHandler){dispatchErrorResponse(r);}else{Util.error('Something bad happened -- write an error handler to figure out '+'what!');}}}});var invokeErrorHandler=bind(this,function(){var r=new AsyncResponse();var err=this.transport.status||-2;if(this.errorHandler){copy_properties(r,{error:err,errorSummary:AsyncRequest.getHTTPErrorSummary(err),errorDescription:AsyncRequest.getHTTPErrorDescription(err)});dispatchErrorResponse(r);}else{Util.error('Async request to %q failed with a %d error, but there was no error '+'handler available to deal with it.',this.uri,err);}});var onStateChange=function(){try{if(this.transport.readyState==4){if(this.transport.status>=200&&this.transport.status<300){invokeResponseHandler();}else{invokeErrorHandler();}}}catch(exception){Util.error('AsyncRequest exception when attempting to handle a state change: %x.',exception);}};var buildTransport=function(obj){var transport=Try.these(function(){return new XMLHttpRequest();},function(){return new ActiveXObject("Msxml2.XMLHTTP");},function(){return new ActiveXObject("Microsoft.XMLHTTP");})||null;if(transport){transport.onreadystatechange=bind(obj,onStateChange);}else{Util.error('Unable to build XMLHTTPRequest transport.');}
return transport;};copy_properties(this,{transport:buildTransport(this),method:'POST',uri:'',handler:null,errorHandler:null,data:null,option:{asynchronous:true,suppressErrorHandlerWarning:false,suppressEvaluation:false}});return this;}
copy_properties(AsyncRequest,{getHTTPErrorSummary:function(errCode){return AsyncRequest._getHTTPError(errCode).summary;},getHTTPErrorDescription:function(errCode){return AsyncRequest._getHTTPError(errCode).description;},pingURI:function(uri,data,synchronous){return new AsyncRequest().setURI(uri).setData(data).setOption('asynchronous',!synchronous).setOption('suppressErrorHandlerWarning',true).send();},_getHTTPError:function(errCode){var e=AsyncRequest._HTTPErrors[errCode]||AsyncRequest._HTTPErrors[errCode-(errCode%100)]||{summary:'HTTP Error',description:'Unknown HTTP error #'+errCode};return e;},_HTTPErrors:{400:{summary:'Bad Request',description:'Bad HTTP request.'},401:{summary:'Unauthorized',description:'Not authorized.'},403:{summary:'Forbidden',description:'Access forbidden.'},404:{summary:'Not Found',description:'URI does not exist.'}}});copy_properties(AsyncRequest.prototype,{setMethod:function(m){this.method=m.toString().toUpperCase();return this;},getMethod:function(){return this.method;},setData:function(obj){this.data=obj;return this;},getData:function(){return this.data;},setURI:function(uri){this.uri=uri;return this;},getURI:function(){return this.uri;},setHandler:function(fn){if(typeof(fn)!='function'){Util.error('AsyncRequest response handlers must be functions. Pass a function, '+'or use bind() to build one.');}else{this.handler=fn;}
return this;},getHandler:function(fn){return this.handler;},setErrorHandler:function(fn){if(typeof(fn)!='function'){Util.error('AsyncRequest error handlers must be functions. Pass a function, or '+'use bind() to build one.');}else{this.errorHandler=fn;}
return this;},getErrorHandler:function(fn){return this.handler;},setOption:function(opt,v){if(typeof(this.option[opt])!='undefined'){this.option[opt]=v;}else{Util.warn('AsyncRequest option %q does not exist; request to set it was ignored.',opt);}
return this;},getOption:function(opt){if(typeof(this.option[opt])=='undefined'){Util.warn('AsyncRequest option %q does not exist, get request failed.',opt);}
return this.option[opt];},send:function(){var query=ajaxArrayToQueryString(this.data);var uri;if(!this.uri){Util.error('Attempt to dispatch an AsyncRequest without an endpoint URI! This is '+'all sorts of silly and impossible, so the request failed.');return false;}
if(!this.errorHandler&&!this.getOption('suppressErrorHandlerWarning')){Util.warn('Dispatching an AsyncRequest that does not have an error handler. '+'You SHOULD supply one, or use AsyncRequest.pingURI(). If this '+'omission is intentional and well-considered, set the %q option to '+'suppress this warning.','suppressErrorHandlerWarning');}
if(this.method=='GET'){uri=this.uri+(query?'?'+query:'');query='';}else{uri=this.uri;}
this.transport.open(this.method,uri,this.getOption('asynchronous'));if(this.method=='POST'){this.transport.setRequestHeader('Content-Type','application/x-www-form-urlencoded');}
this.transport.send(query);return true;}});function AsyncResponse(){copy_properties(this,{error:0,errorSummary:null,errorDescription:null,payload:null});return this;}
copy_properties(AsyncResponse.prototype,{getPayload:function(){return this.payload;},getError:function(){return this.error;},getErrorSummary:function(){return this.errorSummary;},getErrorDescription:function(){return this.errorDescription;}});
/*****deprected.js******/
Util._deprecatedBecause={extend:'extend() has been renamed copy_properties() to avoid confusion with '+'Function.extend(). Use Function.extend() or subclass() to establish class'+'inheritence, and copy_properties() to copy properties between objects.',ajaxrequest:'AjaxRequest has been renamed AsyncRequest. The interface has not '+'changed.',ajaxresponse:'AjaxResponse has been renamed AsyncResponse. The interface has not '+'changed.',ajax:'The `Ajax\' class has been deprecated for sucking. Use AsyncRequest '+'and AsyncResponse to make remote HTTP requests. Prefer JSON to XML as '+'a transport encoding, but never say "AJAJ". AND WRITE ERROR HANDLERS! ',ajaxloadindicator:'No ajaxLoadIndicator element is ever generated, so this code is '+'apparently never used.',mediaheaderpictureload:'This function is deprecated because it solves a problem that should be '+'solved (and can more easily be solved) with CSS.',toggleinlineflyer:'This function is not used anywhere.',checkagree:'This function is marked as deprecated and not used anywhere.',dynamicdialog:'Dynamicdialog is deprecated in favor of dialogpro.'}
function extend(u,v){Util.deprecated('extend');return copy_properties(u,v);}
function checkAgree(){Util.deprecated('checkagree');if(document.frm.pic.value){if(document.frm.agree.checked){document.frm.submit();}else{show("error");}}}
function mediaHeaderPictureLoad(image,size)
{Util.deprecated('mediaheaderpictureload');var w=image.offsetWidth;var h=image.offsetHeight;var ratio=size/h;image.style.height=size+'px';image.style.width=(ratio*w)+'px';image.style.visibility='visible';}
function toggleInlineFlyer(toggler){Util.deprecated('toggleinlineflyer');if(toggler.innerHTML=='hide flyer'){toggler.innerHTML='show flyer';}else{toggler.innerHTML='hide flyer';}
toggle('inline_flyer_content');}
var ajaxLoadIndicatorRefCount=0;function ajaxShowLoadIndicator()
{Util.deprecated('ajaxloadindicator');indicatorDiv=ge('ajaxLoadIndicator');if(!indicatorDiv){indicatorDiv=document.createElement("div");indicatorDiv.id='ajaxLoadIndicator';indicatorDiv.innerHTML='Loading';indicatorDiv.className='ajaxLoadIndicator';document.body.appendChild(indicatorDiv);}
indicatorDiv.style.top=(5+pageScrollY())+'px';indicatorDiv.style.left=(5+pageScrollX())+'px';indicatorDiv.style.display='block';ajaxLoadIndicatorRefCount++;}
function ajaxHideLoadIndicator()
{ajaxLoadIndicatorRefCount--;if(ajaxLoadIndicatorRefCount==0)
ge('ajaxLoadIndicator').style.display='';}
function FBAjax(doneHandler,failHandler)
{Util.deprecated('ajax');newAjax=this;this.onDone=doneHandler;this.onFail=failHandler;this.transport=this.getTransport();this.transport.onreadystatechange=ajaxTrampoline(this);}
FBAjax.prototype.get=function(uri,query,force_sync)
{force_sync=force_sync||false;if(typeof query!='string')
query=ajaxArrayToQueryString(query);fullURI=uri+(query?('?'+query):'');this.transport.open('GET',fullURI,!force_sync);this.transport.send('');}
FBAjax.prototype.post=function(uri,data,force_sync,no_post_form_id)
{force_sync=force_sync||false;no_post_form_id=no_post_form_id||false;if(typeof data!='string'){data=ajaxArrayToQueryString(data);}
if(!no_post_form_id){var post_form_id=ge('post_form_id');if(post_form_id){data+='&post_form_id='+post_form_id.value;}}
this.transport.open('POST',uri,!force_sync);this.transport.setRequestHeader("Content-Type","application/x-www-form-urlencoded");this.transport.send(data);}
FBAjax.prototype.stateDispatch=function()
{try{if(this.transport.readyState==1&&this.showLoad)
ajaxShowLoadIndicator();if(this.transport.readyState==4){if(this.showLoad)
ajaxHideLoadIndicator();if(this.transport.status>=200&&this.transport.status<300&&this.transport.responseText.length>0){try{if(this.onDone)this.onDone(this,this.transport.responseText);}catch(tempError){console?console.error(tempError):false;}}else{try{if(this.onFail)this.onFail(this);}catch(tempError){console?console.error(tempError):false;}}}}catch(error){if(this.onFail)this.onFail(this);}}
FBAjax.prototype.getTransport=function()
{var ajax=null;try{ajax=new XMLHttpRequest();}
catch(e){ajax=null;}
try{if(!ajax)ajax=new ActiveXObject("Msxml2.XMLHTTP");}
catch(e){ajax=null;}
try{if(!ajax)ajax=new ActiveXObject("Microsoft.XMLHTTP");}
catch(e){ajax=null;}
return ajax;}
function ajaxTrampoline(ajaxObject)
{return function(){ajaxObject.stateDispatch();};}
function AjaxRequest(){Util.deprecated('AjaxRequest');return arguments.callee.parent.apply(this,arguments);};subclass(AjaxRequest,AsyncRequest);function AjaxResponse(){Util.deprecated('AjaxResponse');return arguments.callee.parent.apply(this,arguments);};subclass(AjaxRequest,AsyncRequest);function toggle_dynamic_dialog_custom(rootEl,innerHTML){Util.deprecated('dialogpro');var ieHTML;ieHTML='<div id="ie_iframe_holder"></div>';ieHTML+='<div style="position: absolute; z-index: 100;">';innerHTML=ieHTML+innerHTML+'</div>';var dynamic_dialog=ge('dynamic_dialog');if(dynamic_dialog){if(shown(dynamic_dialog)&&same_place(rootEl,dynamic_dialog)){hide(dynamic_dialog);}else{move_here(rootEl,dynamic_dialog);dynamic_dialog.innerHTML=innerHTML;show('dynamic_dialog');}}else{var dynamic_dialog=document.createElement("div");dynamic_dialog.id='dynamic_dialog';dynamic_dialog.innerHTML=innerHTML;move_here(rootEl,dynamic_dialog);ge('content').appendChild(dynamic_dialog);}
var height,width,ieIframeHTML;height=ge('dialog').offsetHeight;width=ge('dialog').offsetWidth;ieIframeHTML='<iframe width="'+width+' "height='+height+'" ';ieIframeHTML+='style="position: absolute; z-index: 99; border: none;"></iframe>';ge('ie_iframe_holder').innerHTML=ieIframeHTML;return false;}
function same_place(rootEl,dynamic_dialog){Util.deprecated('dialogpro');if(rootEl=ge(rootEl)){if(elementY(rootEl)+20==elementY(dynamic_dialog))
return true;}
return false;}
function move_here(rootEl,el){Util.deprecated('dialogpro');var x=getViewportWidth()/2-120;var y=elementY(rootEl)+20;el.style.left=x+"px";el.style.top=y+"px";}
function toggle_dynamic_dialog_post(rootEl,headingText,contentText,confirmText,confirmLocation,confirmParams){Util.deprecated('dialogpro');var form_check_string=(ge('post_form_id')?('<input type="hidden" name="post_form_id" value="'+ge('post_form_id').value+'"/>'):'');var formParams='';for(var param in confirmParams){formParams+='<input type="hidden" name="'+param+'" value="'+
confirmParams[param]+'"/>'}
var innerHTML='<table id="dialog" border="0" cellspacing="0" width="360">'+'<tr>'+'<td class="dialog">'+'<h4>'+headingText+'</h4>'+'<p>'+contentText+'</p>'+'<div class="buttons">'+'<form action="'+confirmLocation+'" method="post">'+
form_check_string+
formParams+'<input type="hidden" name="next" value="'+window.location+'"/>'+'<input type="submit" id="confirm" name="confirm" class="inputsubmit" '+'value="'+confirmText+'"/>&nbsp;<input type="button" id="cancel" '+'name="cancel" onclick="hide(\'dynamic_dialog\');" class="inputbutton" '+'value="Cancel" />'+'</form>'+'</div>'+'</td>'+'</tr>'+'</table>';return toggle_dynamic_dialog_custom(rootEl,innerHTML);}
function toggle_dynamic_dialog(rootEl,headingText,contentText,confirmText,confirmLocation){Util.deprecated('dialogpro');var form_check_string=(ge('post_form_id')?('<input type="hidden" name="post_form_id" value="'+ge('post_form_id').value+'"/>'):'');var innerHTML="<form action=\""+confirmLocation+"\" method=\"post\">\n"+"<table id=\"dialog\" border=\"0\" cellspacing=\"0\" width=\"360\">"+"<tr>\n"+"<td class=\"dialog\">\n"+"<h4>"+headingText+"</h4>\n"+"<p>"+contentText+"</p>"+"<div class=\"buttons\">\n"+
form_check_string+"<input type=\"hidden\" name=\"next\" value=\""+window.location+"\"/>\n"+"<input type=\"submit\" id=\"confirm\" name=\"confirm\" class=\"inputsubmit\" value=\""+confirmText+"\"/>&nbsp;<input type=\"button\" id=\"cancel\" name=\"cancel\" onclick=\"hide('dynamic_dialog');\" class=\"inputbutton\" value=\"Cancel\" />\n"+"</div>\n"+"</td>\n"+"</tr>\n"+"</table>\n"+"</form>\n";return toggle_dynamic_dialog_custom(rootEl,innerHTML);}
function toggle_dynamic_dialog_js(rootEl,headingText,contentText,confirmText,confirmJS,remove_cancel_option){Util.deprecated('dialogpro');var innerHTML="<table id=\"dialog\" border=\"0\" cellspacing=\"0\" width=\"360\">"+"<tr>\n"+"<td class=\"dialog\">\n"+"<h4>"+headingText+"</h4>\n"+"<p>"+contentText+"</p>"+"<div class=\"buttons\">\n"+"<input type=\"button\" id=\"confirm\" name=\"confirm\" class=\"inputsubmit\"  value=\""+confirmText+"\" onclick=\""+confirmJS+"\"/>&nbsp;";if(!remove_cancel_option){innerHTML+="<input type=\"button\" id=\"cancel\" name=\"cancel\" onclick=\"hide('dynamic_dialog');\" class=\"inputbutton\" value=\"Cancel\" />\n";}
innerHTML+="</div>\n"+"</td>\n"+"</tr>\n"+"</table>\n";return toggle_dynamic_dialog_custom(rootEl,innerHTML);}