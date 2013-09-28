class WallController < PluginController 

  before_filter :get_owner
  skip_before_filter :get_owner, :only => :index

  def index
  end

  private 
      def comment_posted body
          comment = @owner.comments.create(:user_id => logged_in_user.id, :body => body)
#          begin
#            msg,users = @owner.notifiable_users("new_wall_msg")         
#            users.delete(logged_in_user)
#            puts send_notification(users,msg)
#          rescue Exception=>e
#            puts e.message
#          end 
          Syndicate::story_for(logged_in_user,"wall_comment",:type=>"wallcomment",:context=>@owner,:locals=>{:comment=>comment})
      end
  public
  def post_comment
    begin
      if @owner.users.find(logged_in_user.id) then
        comment_posted(params[:text])
        #@owner.comments.create(:user_id => logged_in_user.id, :body => params[:text])
      end
      @comments = @owner.comments.find(:all, :order => "created_on DESC", :limit => 10) rescue @comments = []
      render :partial => 'wall/wall_template', :locals => { :owner => @owner, :comments => @comments }
    rescue render_return
    end
  end

  def delete_comment  #this needs to get all params passed to it
    begin
      logged_in_user.comments.destroy(params[:id])      
      @comments = @owner.comments.find(:all, :order => "created_on DESC", :limit => 10) rescue @comments = []
      #render :partial => 'wall/wall_template', :locals => { :owner => @owner, :comments => @comments }
      redirect_to :back
    rescue render_return
    end
  end


  def see_all
    if params[:page] != nil then
      page = params[:page]
    else
      page = 1
    end
    begin
      @c = @owner.comments.find(:all, :order => "created_on DESC") rescue @c = []
      @paginator,@comments = paginate @c, {:per_page => 10, :page => page}
    rescue render_return
    end
  end


  def post_comment_see_all
    begin
      if @owner.users.find(logged_in_user.id) then
        comment_posted(params[:text])
        #@owner.comments.create(:user_id => logged_in_user.id, :body => params[:text])
        params[:sa] = nil
      end
      #c = @owner.comments.find(:all, :order => "created_on DESC") rescue c = []
      #@paginator,@comments = paginate c, {:per_page => 10}
      #render :partial => 'wall/wall_comments', :locals => { :owner => @owner, :paginator => @paginator, :comments => @comments, :total_comments => c.length  }
      fb_redirect_to :controller => 'wall', :action => 'see_all', :cn => @owner.class, :cid => @owner.id
    rescue render_return
    end
   
  end

  def delete_comment_see_all
    begin
      logged_in_user.comments.destroy(params[:id])    
      c = @owner.comments.find(:all, :order => "created_on DESC") rescue c = []
      if c.length < 10 then
        fb_redirect_to @owner.back_url
      else
        @paginator,@comments = paginate c, {:per_page => 10}
        render :partial => 'wall/wall_comments', :locals => { :owner => @owner, :paginator => @paginator, :comments => @comments, :total_comments => c.length }
      end
    rescue render_return
    end
   
  end



  def wallpost
    if params[:text] != nil then
      #save post and
      #return to owner's context home page
      begin
        if @owner.users.find(logged_in_user.id) then
          comment_posted(params[:text])
          #@owner.comments.create(:user_id => logged_in_user.id, :body => params[:text])
        end
        fb_redirect_to @owner.back_url + "#wp1"
      rescue render_return
      end
    else
    end
  end


 private
  def authorize_user
    true
  end

  def get_owner
    @owner = (params[:cn] || "").constantize().find(params[:cid]) rescue render_return
  end

end
