module ProfileHelper
  class Story
      attr_accessor :headline,:body
      def initialize headline,body
          @headline=headline;
          @body=body
      end
  end
  def feed_quote quote,&block
     actions = []
     if block_given?
        capture(actions,&block)        
     end
     actions = actions.map { |a_name,a_url|
        fb_link_to(a_name,a_url)
     }.join(fb_pipe)
     unless actions.empty?
       actions = content_tag(:div,actions,:style=>"clear:left;padding-top:10px")
     else
       actions = nil
     end
     quote = if quote.to_s.size > 0 
               <<-eof
                  <div class="quote" style='background:transparent url(http://www.facebook.com/images/start_quote.gif) no-repeat scroll left top'>
                      <span class="em" style='background:transparent url(http://www.facebook.com/images/end_quote.gif) no-repeat scroll right bottom;'>
                          #{quote}
                      </span>
                   </div>     
               eof
             else
                ""
             end
     <<-eof  
      <div style='padding-left:40px'>
         #{quote}
         #{actions}  
       </div>
     eof
     
  end
  def headline &block
      @headline = capture(&block).strip.sub(/\.$/,'');
      @headline << "."
  end
  def body &block
      @body = capture(&block)
  end
  def actioner(feed,anonymous=false)
      uid = anonymous ? -1 : feed.user_id
      fbml_name(uid,:ifcantsee=>"Someone")
  end

  def publish(feed)
       @headline=@body=nil;
       render_p("stories/" + feed.story_partial,feed.story_locals)      
       return Story.new(@headline,@body)
  end
  def randomly weight=1,&block
     percentage = weight * 100   
     random_number = rand(101)
     return if random_number > percentage
     concat(capture(&block),block.binding)
  end
  def select_random
  
  end
  
end