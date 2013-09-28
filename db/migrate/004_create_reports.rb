class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.column :reportable_type, :string, :null => false
      t.column :reportable_id, :integer, :null => false
      t.column :reporter_id, :integer,:null => false
      t.column :user_id,:integer,:null => false
      t.column :resolved,:boolean
      t.column :subject,:string,:limit=>100,:null=>false
      t.column :body, :string, :limit => 1000, :null => false
      t.column :created_on, :datetime
    end
    add_index "reports",["reportable_type","reportable_id"]
    
  end
  def self.down
   drop_table :reports
  end
end
