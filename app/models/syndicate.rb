class Syndicate < ActiveRecord::Base
    #belongs_to :syndicatable, :polymorphic => true    
    JoinOrLeaveClass = "joinorleaveclass"
    PostDocument = "postdoc"
    ChangeClassElement = "modclass"    
    def self.story_for(user,partial_template,options={})
       news_type = options.delete(:type)              
       partial_variables = options.delete(:locals) || {}
       feed = new(:user_id=>user.id,:news_type=>news_type,:story_partial=>partial_template,:story_locals=>Marshal.dump(partial_variables))
       if options[:context] 
          syndicatable = options[:context]
          feed.attributes = {:context_type=>syndicatable.class.to_s,:context_id=>syndicatable.id}        
       end
       feed.save
    end
    def has_body?
        self.story_partial.to_s.size > 0
    end
    def story_locals
      context = self[:context_type].constantize().find(self[:context_id]) rescue nil
      Marshal.load(self['story_locals']).merge(:context=>context,:feed=>self)
    end
end