class DiscussionController < ApplicationController

  before_filter :get_owner
  skip_before_filter :get_owner, :only => :index

  def index
  end
  
  
  
  ################################################
  # Topic Methods
  ################################################
  
  # Starts a new topic
  def start_new_topic
    @topic = Topic.new
    @post = Post.new

    if params[:submit_button]      
      begin
        if params[:is_anonymous] == 'on' then
          anon_value = true
        else
          anon_value = false
        end
        @topic.name = params[:name]
        @topic.is_anonymous = anon_value
        @topic.user_id = logged_in_user.id
        
        if not @topic.valid?
         raise_after_msg 'error', :title=>@topic.errors.on('name')
        end
        

        @post.user_id = @topic.user_id
        @post.is_first_post = true
        @post.is_anonymous = anon_value
        @post.body = params[:body]

        if not @post.valid?
         flash[:title] = @topic.name
         raise_after_msg 'error', :title=>@post.errors.on('body')
        end

        @owner.topics << @topic
        @topic.posts << @post
        Syndicate::story_for(logged_in_user,'newtopic',:type=>"newtopic",:context=>@owner,:locals=>{:topic_id=>@topic.id})
        fb_redirect_to :controller => 'discussion', :action => 'topics', :cn => params[:cn], :cid => params[:cid]
        return
      rescue Exception=>e
        p e.message
        p flash.inspect
        fb_redirect_to :controller => 'discussion', :action => 'start_new_topic', :cn => params[:cn], :cid => params[:cid]
        return
      end
    else
        @topic.name = flash[:title]
        @post.body = flash[:body]
    end
  end

  # Displays the list of topics
  def topics
    begin
      case params[:filter].to_i
        when 0:  #everyone. unfiltered.
          @topics = @owner.topics.unfiltered
        when 1:  #my topics
          @topics = @owner.topics.by_userlist(logged_in_user.id)
        when 2:  #my friend's topics
          @topics = @owner.topics.by_userlist(logged_in_user.friends)
        when 3:  #topics by classmates
          #@topics = @owner.topics.by_userlist(@logged_in_user.classmates)
          @topics = @owner.topics.unfiltered
        else
          params[:filter] = 0
          @topics = @owner.topics.unfiltered
      end
      case params[:sorter].to_i
        when 0:  #latest replies
          @topics.sort! { |x,y| y.latest_post.created_on <=> x.latest_post.created_on}
        when 1:  #newest posts
          @topics.sort! { |x,y| y.created_on <=> x.created_on }
        when 2:  #most people
          @topics.sort! { |x,y| y.people_count <=> x.people_count }
        when 3:  #most posts
          @topics.sort! { |x,y| y.posts.count <=> x.posts.count }
        else
          params[:sorter] = 0
          @topics.sort! { |x,y| y.latest_post.created_on <=> x.latest_post.created_on}
      end
    rescue Exception => e #render_return
      puts e.inspect
    end
  end
  
  # Displays a given topic and all related posts
  def topic
    begin
      @topic = @owner.topics.find(params[:id])
    rescue render_return
    end
  end

  # Does this one really need an explanation?
  def delete_topic
    begin
      if logged_in_user.is_admin? then
        topic = Topic.find(params[:id])
      else
        topic = logged_in_user.topics.find(params[:id])
      end
      topic.posts.each do |post|
        post.destroy
      end
      topic.destroy
        
      if @owner.topics.count > 0 then 
        fb_redirect_to :controller => 'discussion', :action => 'topics', :cn => @owner.class, :cid => @owner.id
      else
        fb_redirect_to @owner.back_url
      end
    rescue render_return
    end
  end
  

  ################################################
  # Post Methods
  ################################################

  #
  def reply_to_topic
    @post = Post.new
    begin
      if params[:submit_button] then 
      
        if params[:is_anonymous] == 'on' then
          anon_value = true
        else
          anon_value = false
        end
      
        @post.user_id = logged_in_user.id
        @post.reply_id = nil
        @post.is_first_post = false
        @post.is_anonymous = anon_value
        @post.body = params[:body]

        if not @post.valid?
          raise_after_msg 'error', :title=>@post.errors.on('body')
        end
      
        @owner.topics.find(params[:id]).posts << @post 
        
        fb_redirect_to :controller => 'discussion', :action => 'topic', :id => params[:id], :cn => @owner.class, :cid => @owner.id
        return
      else
        @topic = @owner.topics.find(params[:id])
      end
    rescue Exception=>e
      fb_redirect_to :controller => 'discussion', :action => 'reply_to_topic', :id => params[:id], :cn => @owner.class, :cid => @owner.id
      return
    end
  end

  #
  def reply_to_post
    @post = Post.new
    puts params.inspect
    begin
      if params[:submit_button] then 
      
        if params[:is_anonymous] == 'on' then
          anon_value = true
        else
          anon_value = false
        end
      
        @post.user_id = logged_in_user.id
        @post.reply_id = params[:pid]
        @post.is_first_post = false
        @post.is_anonymous = anon_value
        @post.body = params[:body]

        if not @post.valid?
          raise_after_msg 'error', :title=>@post.errors.on('body')
        end

        @owner.topics.find(params[:id]).posts << @post 
        
        fb_redirect_to :controller => 'discussion', :action => 'topic', :id => params[:id], :cn => @owner.class, :cid => @owner.id
        return
      else
        @topic = @owner.topics.find(params[:id])
        @post = @topic.posts.find(params[:pid])
      end
    rescue Exception=>e
      puts e
      fb_redirect_to :controller => 'discussion', :action => 'reply_to_post', :id => params[:id], :cn => @owner.class, :cid => @owner.id, :pid => params[:pid]
      return
    end
  end


  #
  def edit_post
    @topic = logged_in_user.topics.find(params[:id])
    @post = @owner.topics.find(params[:id]).posts.find(params[:pid]) rescue render_return
    if params[:submit_button] then
      begin
        @post.body = params[:body]
        
        if params[:is_anonymous] == 'on' then
          anon_value = true
        else
          anon_value = false
        end

        @post.is_anonymous = anon_value
       
        if not @post.valid? || @post == nil then 
          raise_after_msg 'error', :title=>@post.errors.on('body')
        end

        @post.save
        
        fb_redirect_to :controller => 'discussion', :action => 'topic', :id => params[:id], :cn => @owner.class, :cid => @owner.id, :pid => params[:pid]
        return
      rescue Exception => e

        fb_redirect_to :controller => 'discussion', :action => 'edit_post', :id => params[:id], :cn => @owner.class, :cid => @owner.id, :pid => params[:pid]
        return
      end
    else
      
    end
  end


  #
  def delete_post
    begin
    
     if logged_in_user.is_admin? then
        topic = Topic.find(params[:id])
      else
        topic = logged_in_user.topics.find(params[:id])
      end
  
      post = topic.posts.find(params[:pid])

      post_count = topic.posts.count

      if post.is_first_post == true then
        topic.posts.each do |post|
          post.destroy
        end
        topic.destroy

        if @owner.topics.count > 0 then 
          fb_redirect_to :controller => 'discussion', :action => 'topics', :cn => @owner.class, :cid => @owner.id
        else
          fb_redirect_to @owner.back_url
        end

      else
        post.destroy()

        fb_redirect_to :controller => 'discussion', :action => 'topic', :id => params[:id], :cn => @owner.class, :cid => @owner.id
      end
      
    rescue render_return
    end
  end


  private
  
  def get_owner
      @owner = params[:cn].to_s.constantize.find(params[:cid]) rescue render_return
  end


end
