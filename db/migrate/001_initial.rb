class Initial < ActiveRecord::Migration
  def self.up
  
    create_table "courses", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "subject_id", :integer, :default => 0, :null => false
      t.column "subject_code", :string, :limit => 30
      t.column "number", :string, :limit => 10, :default => "", :null => false
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "credit", :float, :default => 0.0
      t.column "description", :string, :limit => 5000
    end
  
    add_index "courses", ["subject_id", "number", "school_id"], :name => "courses_subject_id_index", :unique => true
   
    create_table "klass_schedules", :force => true do |t|
      t.column "klass_id", :integer, :default => 0, :null => false
      t.column "start_time", :string, :limit => 5, :default => "", :null => false
      t.column "day_of_week", :enum, :limit => [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
      t.column "end_time", :string, :limit => 5, :default => "", :null => false
    end
  
    add_index "klass_schedules", ["start_time", "end_time", "day_of_week", "klass_id"], :name => "klass_schedules_start_time_index", :unique => true
  
    create_table "klasses", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "course_id", :integer, :default => 0, :null => false
      t.column "semester_id", :integer, :default => 0, :null => false
      t.column "room", :string, :limit => 30
      t.column "division", :integer, :limit => 6, :default => 0, :null => false
    end
    add_index "klasses", ["school_id","course_id","semester_id"]
    add_index "klasses", ["course_id","semester_id"]  
    add_index "klasses", ["school_id","semester_id"] ,:name=>"school_id1"
    
    create_table "klasses_users", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "semester_id", :integer, :default => 0, :null => false
      t.column "klass_id", :integer, :default => 0, :null => false
      t.column "course_id", :integer, :default => 0, :null => false
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "role_id", :integer, :default => 0, :null => false
      t.column "created_on", :datetime, :null => false
    end
  
    add_index "klasses_users", ["user_id","semester_id"],:name=>"user_id_1"
    add_index "klasses_users", ["user_id","klass_id"],:name=>"user_id_2"
    
    create_table "roles", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "parent_id", :integer
      t.column "lft", :integer
      t.column "rgt", :integer      
    end
  
    add_index "roles", ["name"], :name => "name", :unique => true
      
    create_table "schools", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "city",:string, :limit => 100, :default => "", :null => false
      t.column "region",:string, :limit => 100, :default => "", :null => false
      t.column "country",:string, :limit => 100, :default => "", :null => false
      t.column "created_on", :datetime
    end
    
    create_table "schools_users", :force => true do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "role_id", :integer, :default => 0, :null => false
      t.column "account_status", :enum, :limit => [:activated, :fb_status_changed, :suspended]
      t.column "fb_status", :string, :limit => 30      
      t.column "updated_on", :datetime
    end
  
    add_index "schools_users", ["user_id", "school_id"], :name => "schools_users_user_id_index", :unique => true
  
    create_table "seasons", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "name", :string, :limit => 30
      t.column "start_day", :integer, :limit => 2
      t.column "start_month", :integer, :limit => 2
      t.column "end_month", :integer, :limit => 2
      t.column "end_day", :integer, :limit => 2
      t.column "season_index", :integer, :limit => 2
    end
  
    add_index "seasons", ["school_id", "name"], :name => "school_id", :unique => true
  
    create_table "semesters", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "season_id", :integer, :default => 0, :null => false
      t.column "start_date", :datetime
      t.column "end_date", :datetime
    end   
    
    add_index "semesters",["school_id","start_date","end_date"]
    
    create_table "subjects", :force => true do |t|
      t.column "school_id", :integer, :default => 0, :null => false
      t.column "code", :string, :limit => 30, :default => "", :null => false
      t.column "name", :string, :limit => 100, :default => "", :null => false
    end
  
    add_index "subjects", ["code", "name", "school_id"], :name => "subjects_code_index", :unique => true
  
    create_table "users", :force => true do |t|
      t.column "account_status", :enum, :limit => [:activated, :suspended, :deactivated]
      t.column "created_on", :datetime
      t.column "profile_updated_on", :datetime
      t.column "access_time", :datetime
    end
    create_table "document_files", :force => true do |t|
      t.column "document_id", :integer, :limit => 11, :default => 0, :null => false
      t.column "file_name",:string,:limit=>"500"
      t.column "data", "longblob"
    end
    
    add_index "document_files",["document_id"]

    create_table "documents", :force => true do |t|
      t.column "user_id", :integer, :limit => 11, :default => 0, :null => false    
      t.column "course_id", :integer, :limit => 11, :default => 0, :null => false      
      t.column "school_id", :integer, :limit => 11, :default => 0, :null => false  
      t.column "title", :string, :limit => 100, :default => "", :null => false
      t.column "comment", :string, :limit => 500
      t.column "links", :string,:limit=>"30000"
      t.column "anonymous", :enum, :limit => [:y]
      t.column "num_views",:integer,:default => 0 
      t.column "updated_on",:datetime
      t.column "semester_id",:integer,:default => 0 
      t.column "privacy",:string,:limit => 20
      t.column "created_on", :datetime, :null => false
    end
    add_index "documents",["title","privacy"]
    add_index "documents",["school_id","privacy"]
    add_index "documents",["course_id","privacy"]
    add_index "documents",["privacy"]
  end
  def self.down

  end
end
