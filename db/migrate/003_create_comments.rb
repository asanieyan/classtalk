class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :commentable_type, :string, :null => false
      t.column :commentable_id, :integer, :null => false
      t.column :user_id, :integer
      t.column :body, :string, :limit => 1000, :null => false
      t.column :created_on, :datetime
    end
    add_index :comments, [:commentable_type, :commentable_id]
  end

  def self.down
    drop_table :comments
  end
end
