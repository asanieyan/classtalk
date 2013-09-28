function generic_dialog(className){this.className=className;this.content=null;this.obj=null;this.popup=null;this.iframe=null;this.hidden_objects=new Array();}
generic_dialog.prototype.should_hide_objects=navigator.userAgent.indexOf('Mac OS X')!=-1;generic_dialog.prototype.should_use_iframe=navigator.userAgent.indexOf('MSIE 6.0')!=-1;generic_dialog.prototype.show_dialog=function(html){if(!this.obj){this.build_dialog();}
set_inner_html(this.content,html);if(generic_dialog.prototype.should_hide_objects){var imgs=this.content.getElementsByTagName('img');for(var i=0;i<imgs.length;i++){imgs[i].onload=imgs[i].onload?function(){this.onload.apply(this.img,arguments);this.dialog.hide_objects()}.bind({img:imgs[i],dialog:this,onload:imgs[i].onload}):this.hide_objects.bind(this);}}
this.show();return this;}
generic_dialog.prototype.set_top=function(top){return this;}
generic_dialog.prototype.show_ajax_dialog_custom_loader=function(html,src){this.show_dialog('<div class="dialog_loading">'+html+'</div>');var myself=this;var ajax=new FBAjax(function(obj,text){myself.show_dialog(text);});ajax.get(src);return this;}
generic_dialog.prototype.show_ajax_dialog=function(src){var load='Loading...';return this.show_ajax_dialog_custom_loader(load,src);}
generic_dialog.prototype.show_prompt=function(title,content){return this.show_dialog('<h2><span>'+title+'</span></h2><div class="dialog_content">'+content+'</div>');}
generic_dialog.prototype.show_message=function(title,content,button){if(button==null){button='Okay';}
return this.show_choice(title,content,button,function(){generic_dialog.get_dialog(this).fade_out(100)});}
generic_dialog.prototype.show_choice=function(title,content,button1,button1js,button2,button2js,buttons_left_msg,button3,button3js){var buttons='<div class="dialog_buttons" id="dialog_buttons">';if(typeof(buttons_left_msg)!='undefined'){buttons+='<div class="dialog_buttons_left_msg">';buttons+=buttons_left_msg;buttons+='</div>';}
buttons+='<input class="inputsubmit" type="button" value="'+button1+'" />';if(button2){buttons+='<input class="inputsubmit" type="button" value="'+button2+'" />';}
if(button3){buttons+='<input class="inputsubmit" type="button" value="'+button3+'" />';}
this.show_prompt(title,this.content_to_markup(content)+buttons);var inputs=this.obj.getElementsByTagName('input');if(button3){button1obj=inputs[inputs.length-3];button2obj=inputs[inputs.length-2];button3obj=inputs[inputs.length-1];}else if(button2){button1obj=inputs[inputs.length-2];button2obj=inputs[inputs.length-1];}else{button1obj=inputs[inputs.length-1];}
if(button1js){if(typeof button1js=='string'){eval('button1js = function(){'+button1js+'}');}
button1obj.onclick=button1js;}
if(button2js){if(typeof button2js=='string'){eval('button2js = function(){'+button2js+'}');}
button2obj.onclick=button2js;}
if(button3js){if(typeof button3js=='string'){eval('button3js = function(){'+button3js+'}');}
button3obj.onclick=button3js;}
document.onkeyup=function(e){var keycode=(e&&e.which)?e.which:event.keyCode;var btn2_exists=(typeof button2obj!='undefined');var btn3_exists=(typeof button3obj!='undefined');var is_webkit=(navigator.userAgent.indexOf('WebKit')>0);if(is_webkit&&keycode==13){button1obj.click();}
if(keycode==27){if(btn3_exists){button3obj.click();}if(btn2_exists){button2obj.click();}else{button1obj.click();}}
document.onkeyup=function(){}}
button1obj.focus();return this;}
generic_dialog.prototype.show_form=function(title,content,button,target){content='<form action="'+target+'" method="post">'+this.content_to_markup(content);var post_form_id=ge('post_form_id');if(post_form_id){content+='<input type="hidden" name="post_form_id" value="'+post_form_id.value+'" />';}
content+='<div class="dialog_buttons"><input class="inputsubmit" name="confirm" type="submit" value="'+button+'" />';content+='<input type="hidden" name="next" value="'+htmlspecialchars(document.location)+'"/>';content+='<input class="inputsubmit" type="button" value="Cancel" onclick="generic_dialog.get_dialog(this).fade_out(100)" /></form>';this.show_prompt(title,content);return this;}
generic_dialog.prototype.content_to_markup=function(content){return(typeof content=='string')?'<div class="dialog_body">'+content+'</div>':'<div class="dialog_summary">'+content.summary+'</div><div class="dialog_body">'+content.body+'</div>';}
generic_dialog.prototype.hide=function(){if(this.obj){this.obj.style.display='none';}
if(this.iframe){this.iframe.style.display='none';}
if(this.timeout){clearTimeout(this.timeout);this.timeout=null;return;}
if(this.hidden_objects.length){for(var i in this.hidden_objects){this.hidden_objects[i].style.visibility='';}
this.hidden_objects=new Array();}
return this;}
generic_dialog.prototype.anim_res=5;generic_dialog.prototype.fade_out=function(interval,timeout,first_call){if(timeout){this.timeout=setTimeout(function(){this.fade_out(interval)}.bind(this),timeout);return this;}else if(this.timeout){clearTimeout(this.timeout);this.timeout=null;}
if(!interval)
interval=350;if(!first_call)
first_call=(new Date).getTime()-this.anim_res;var fade=1.0-(((new Date).getTime()-first_call)/interval)*1.0;if(fade>0){set_opacity(this.obj,fade);setTimeout(function(){this.fade_out(interval,0,first_call)}.bind(this),this.anim_res);}
else{this.hide();set_opacity(this.obj,1);}
return this;}
generic_dialog.prototype.show=function(){if(this.obj&&this.obj.style.display){this.obj.style.visibility='hidden';this.obj.style.display='';this.reset_dialog();this.obj.style.visibility='';this.obj.dialog=this;}
else{this.reset_dialog();}
this.hide_objects();return this;}
generic_dialog.prototype.enable_buttons=function(enable){var inputs=this.obj.getElementsByTagName('input');for(var i=0;i<inputs.length;i++){if(inputs[i].type=='button'||inputs[i].type=='submit'){inputs[i].disabled=!enable;}}}
generic_dialog.prototype.hide_objects=function(){var objects=new Array();var ad_locs=['',0,1,2,9,3];for(var i=0;i<ad_locs.length;i++){var ad_div=ge('ad_'+ad_locs[i]);if(ad_div!=null){objects.push(ad_div);this.should_hide_objects=true;}}
if(!this.should_hide_objects){return;}
var rect={x:elementX(this.content),y:elementY(this.content),w:this.content.offsetWidth,h:this.content.offsetHeight};var iframes=document.getElementsByTagName('iframe');for(var i=0;i<iframes.length;i++){if(iframes[i].className.indexOf('share_hide_on_dialog')!=-1){objects.push(iframes[i]);}}
var swfs=document.getElementsByTagName('embed');for(var i=0;i<swfs.length;i++){objects.push(swfs[i]);}
for(var i=0;i<objects.length;i++){var pn=false;var node=objects[i].offsetHeight?objects[i]:objects[i].parentNode;swf_rect={x:elementX(node),y:elementY(node),w:node.offsetWidth,h:node.offsetHeight};if(rect.y+rect.h>swf_rect.y&&swf_rect.y+swf_rect.h>rect.y&&rect.x+rect.w>swf_rect.x&&swf_rect.x+swf_rect.w>rect.w&&array_indexOf(this.hidden_objects,node)==-1){this.hidden_objects.push(node);node.style.visibility='hidden';node.style.visibility='hidden';}}}
generic_dialog.prototype.build_dialog=function(){if(!this.obj&&!(this.obj=ge('generic_dialog'))){this.obj=document.createElement('div');this.obj.id='generic_dialog';}
this.obj.className='generic_dialog'+(this.className?' '+this.className:'');this.obj.style.display='none';document.body.appendChild(this.obj);if(this.should_use_iframe){if(!this.iframe&&!(this.iframe=ge('generic_dialog_iframe'))){this.iframe=document.createElement('iframe');this.iframe.id='generic_dialog_iframe';}
this.iframe.frameBorder='0';document.body.appendChild(this.iframe);}
if(!this.popup&&!(this.popup=ge('generic_dialog_popup'))){this.popup=document.createElement('div');this.popup.id='generic_dialog_popup';}
this.popup.style.left=this.popup.style.top='';this.obj.appendChild(this.popup);}
generic_dialog.prototype.reset_dialog=function(){if(!this.popup)
return;this.reset_dialog_obj();this.reset_iframe();}
generic_dialog.prototype.reset_iframe=function(){if(!this.should_use_iframe){return;}
this.iframe.style.left=elementX(this.frame)+'px';this.iframe.style.top=elementY(this.frame)+'px';this.iframe.style.width=this.frame.offsetWidth+'px';this.iframe.style.height=this.frame.offsetHeight+'px';this.iframe.style.display='';}
generic_dialog.prototype.reset_dialog_obj=function(){}
generic_dialog.prototype.set_width=function(w){this.obj.style.width=w?w+'px':'';}
generic_dialog.get_dialog=function(obj){while(!obj.dialog&&obj.parentNode){obj=obj.parentNode;}
return obj.dialog?obj.dialog:false;}
function pop_dialog(className){this.top=125;this.parent.construct(this,className);}
pop_dialog.extend(generic_dialog);pop_dialog.prototype.build_dialog=function(){this.parent.build_dialog();this.obj.className+=' pop_dialog';this.popup.innerHTML='<table class="pop_dialog_table">'+'<tr><td class="pop_topleft"></td><td class="pop_border"></td><td class="pop_topright"></td></tr>'+'<tr><td class="pop_border"></td><td class="pop_content" id="pop_content"></td><td class="pop_border"></td></tr>'+'<tr><td class="pop_bottomleft"></td><td class="pop_border"></td><td class="pop_bottomright"></td></tr>'+'</table>';this.frame=this.popup.getElementsByTagName('tbody')[0];this.content=document.getElementById('pop_content');}
pop_dialog.prototype.reset_dialog_obj=function(){this.popup.style.top=(document.documentElement.scrollTop?document.documentElement.scrollTop:document.body.scrollTop)+this.top+'px';}
pop_dialog.prototype.set_top=function(top){this.top=top;}
function contextual_dialog(className){this.parent.construct(this,className);}
contextual_dialog.extend(generic_dialog);contextual_dialog.prototype.set_context=function(obj){this.context=obj;}
contextual_dialog.prototype.build_dialog=function(){this.parent.build_dialog();this.obj.className+=' contextual_dialog';this.popup.innerHTML='<div class="contextual_arrow"><span>^_^keke1</span></div><div class="contextual_dialog_content"></div>';this.arrow=this.popup.getElementsByTagName('div')[0];this.content=this.frame=this.popup.getElementsByTagName('div')[1];}
contextual_dialog.prototype.reset_dialog_obj=function(){var x=elementX(this.context);var width=this.popup.offsetWidth-this.arrow_padding;var center=(document.body.offsetWidth-width)/2;var left=Math[(center<x)?'max':'min'](center,x-width);this.popup.style.top=(elementY(this.context)+5)+'px';this.popup.style.left=left+'px';this.arrow.style.backgroundPosition=(x-left-this.arrow_width)+'px';}
contextual_dialog.prototype.arrow_padding=12;contextual_dialog.prototype.arrow_width=13;