class Topic < ActiveRecord::Base

  has_many :posts
  belongs_to :user
  belongs_to :discussable, :polymorphic => true
  escape_once_and_truncate 'name'

  def validate
    errors.add('name',"Please enter a title.") if name.size == 0
  end
  def header
    self.posts.find(:first)
  end
  #a topic is anonymous if the first post is who initiated a topic is anonymous
  #if there is not first post then the there should be no topic  
  def is_anonymous
    self.posts.find(:first).is_anonymous
  end
  #this function gets the total number of people involved in a given topic based on unique IDs
  def people_count
    self.posts.find(:all, :select => "DISTINCT user_id").length
  end

  def latest_post
    self.posts.find(:first, :order => "created_on DESC")
  end

end
