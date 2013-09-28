class ProfileController < ApplicationController
  skip_before_filter :update_affiliations,:only=>%w(save_settings)
  def code 
      if logged_in_user.get_setting("code_entered",false).bool_val          
          render_return :action=>"index",:i=>1 
      end
      if params[:commit] 
          promo = Promo.find(:first,:conditions=>["code LIKE ?",params[:code].to_s.upcase]) 
          promo.increment!("counter") if promo
          logged_in_user.save_setting("code_entered",true)
          fb_redirect_to :action=>"index",:i=>1
          return
      end
      
  end
  def index
    if params[:i]        
        if !logged_in_user.get_setting("code_entered",false).bool_val
            if @new_user 
              render_return :action=>"code" 
            else
              logged_in_user.save_setting("code_entered",true)
            end
        elsif !logged_in_user.get_setting("first_invite",false).bool_val
          if invite_assessment[:invitable].size > 0
            render_return :partial=>'invite_template'
          else
            logged_in_user.save_setting("first_invite",true)
          end
        end         
    end
      
  end
  def invite_assessment
     nids = School.find(:all).map(&:id)
     nid_query = "'college' IN  affiliations.type"
     uids = logged_in_user.friends.to_s
     query = "SELECT uid,affiliations.nid FROM user WHERE uid IN (#{uids}) AND (#{nid_query})"    
     friends_in_college = fbsession.fql_query(:query=>query )
     friends_in_college.each do |friend|
        friend['nids'] = friend['affiliations'].map{|aff| aff['nid']}#.select {|nid| nids.include?(nid) }
        friend.delete('affiliations')
     end
     invitable = []
     invited = []
     reg = [] 
     friends_in_college.each{|f|      
         if (User.find(f['uid']) rescue false) 
            reg << f
         else
            if Invite.check_invited(logged_in_user.id,f['uid'],'friend')
                invited << f
            else
                invitable << f
            end
         end     
     }  
     return {:college=>friends_in_college,
             :registered=>reg,
             :invitable=>invitable,
             :invited=>invited}
  end
#  private :invite_assessment
  #recieves bunch of uid from the user that are supposed to be friends 
  #then sends them invitation
  #don't need to do any checking because if the uids are fake then nothing will happen
  def invite_friends    
      if !params[:ids].to_a.empty?      
          params[:ids].each do |uid|
              if invite = Invite.check_invited(logged_in_user.id,uid,'friend')       
                invite.save
              else
                Invite.create(:invitee_id=>uid,:inviter_id=>logged_in_user.id,:invite_type=>"friend")
              end               
          end
          logged_in_user.save_setting("first_invite",true)
      end
      fb_redirect_to :action=>"index"
  end
  def friends      
      unless params[:t] == 'i'
        if params[:k]
          begin
            @friends = (@klass = Klass.find(params[:k])).users.find(:all,:conditions=>"user_id IN (#{logged_in_user.friends.to_s})")
          rescue Exception=>e
            logger.info e.message rescue nil
          end
        end
        @friends ||= logged_in_user.friends_here
        @paginator,@friends = paginate logged_in_user.friends_here
      else
        @friends = logged_in_user.friends_here
      end
  end
  def post_add
      begin
        name = render_to_string :inline=>" is now using <%=fb_link_to 'Classtalk',''%>."
        body = render_to_string :inline=>"<b> Join your real class network at <%=fb_link_to 'Classtalk',''%>.</b>"
        fbsession.feed_publishActionOfUser :title=>name,:body=>body
      rescue

      end
      fb_redirect_to :action=>"index"
  end
#  def save_settings
#      notifications = logged_in_user.notifications.map{|ntfc| ntfc[1]}
#      notifications.each do |notif|
#          if params[notif] == "1"
#            logged_in_user.save_setting(notif,true)
#          else
#            logged_in_user.save_setting(notif,false)
#          end
#      end
#      render :inline=>"<%=fbml_success 'Settings Saved'%>"
#  end
#  def notice_comment
#      begin
#        notice = logged_in_user.change_notices.find(params[:notice_id])
#        raise if notice.resolved
#        notice['user_comment'] = params[:comment]
#        notice.save
#      rescue Exception=>e       
#        render_return
#      end
#      render :text=>notice.user_comment
#  end
#  def index
#      render :text=>"hey"
#  end
#  def post_install
#     fbsession.profile_setFBML(:markup=>"<fb:profile-action url='#{fb_url_for :controller=>"user",:action=>"class_profile"}'>ClassTalk Profile</fb:profile-action>")
#     fb_redirect_to :controller=>"home",:action=>"index"
#  end
end