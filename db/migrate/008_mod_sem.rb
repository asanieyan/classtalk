class ModSem < ActiveRecord::Migration
    def self.up    
        add_column :semesters,"next_sem_id", :integer, :default => 0, :null => false
        add_column :semesters, "pre_sem_id", :integer, :default => 0, :null => false

        Semester.reset_column_information
    end
    def self.down
        remove_index  :semesters,"semesters_school_id_index"
        remove_column :semesters,"next_sem_id"
        remove_column :semesters,"pre_sem_id"
    end    
#   def self.up
#    create_table "status_change_notices", :force => true do |t|
#      t.column "user_id", :integer, :default => 0, :null => false
#      t.column "school_id", :integer, :default => 0, :null => false
#      t.column "old_role_id", :string, :limit => 30
#      t.column "new_role_id", :string, :limit => 30
#      t.column "user_comment", :string, :limit => 500
#      t.column "resolved", :boolean
#      t.column "created_on", :datetime
#    end
#  end
#  def self.down
#    drop_table :status_change_notices  
#  end
end