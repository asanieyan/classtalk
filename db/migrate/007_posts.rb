class Posts < ActiveRecord::Migration

  def self.up
  
  
     create_table "topics", :force => true do |t|
        t.column "user_id", :integer, :default => 0, :null => false
        t.column "discussable_id", :integer, :default => 0, :null => false
        t.column "discussable_type", :string, :default => "", :null => false
        t.column "name", :string, :limit=>100, :null => false
        t.column "body", :string, :limit => 3000, :default => "", :null => false
        t.column "is_anonymous", :boolean
        t.column "created_on", :datetime
        t.column "last_updated", :datetime
      end
  
    add_index :topics,["discussable_id","discussable_type"]
      
    create_table "posts", :force => true do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "reply_id", :integer
      t.column "topic_id", :integer, :default => 0, :null => false
      t.column "body", :string, :limit => 2000, :default => "", :null => false
      t.column "is_first_post", :boolean
      t.column "is_anonymous", :boolean
      t.column "created_on", :datetime
      t.column "last_updated", :datetime
    end
    add_index :posts,["topic_id"]

  end
  def self.down
   drop_table :topics
   drop_table :posts
  end


end