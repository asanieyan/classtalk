class Post < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic

  escape_once_and_truncate 'body'
  
  def validate
      errors.add('body',"Please enter text for the body.") if body.size == 0
  end

  acts_as_reportable "Attacks individual or group.", "Advertising/Spam", 
      :owner=>"user", 
      :title=>'Report This Post'
  #whoever sees this can report it
  #that means must be in the same school
  def can_report?(reporting_user)      
      return self.user.schools.detect{|s|
        reporting_user.schools.include?(s)
      }
  end
  def url
    
    {:controller => 'discussion', :action => 'topic', :id => self.topic_id, :cn => self.topic.discussable_type, :cid => self.topic.discussable_id}
  end
end
