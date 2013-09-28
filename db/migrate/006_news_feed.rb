class NewsFeed < ActiveRecord::Migration

  def self.up
    create_table :syndicates do |t|
      t.column :user_id,:integer
      t.column :news_type,:string
      t.column :story_partial,:string
      t.column :story_locals,:binary
      t.column :context_type,:string
      t.column :context_id,:string
      t.column :created_on,:datetime
    end
    add_index :syndicates,["context_type","context_id"]
    add_index :syndicates,["user_id","context_type","context_id"]
  end
  def self.down
   drop_table :syndicates
  end


end