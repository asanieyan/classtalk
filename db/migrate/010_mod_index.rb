class ModIndex < ActiveRecord::Migration
     def self.up
        remove_index :courses,:name=>"courses_subject_id_index"
        
        
        add_index :courses,[:school_id,:subject_id,:number],:unique=>true 
        add_index :courses,[:school_id,:name,:number],:name=>"index_on_name"
        add_index :courses,[:school_id,:subject_code,:number],:name=>"index_on_subject_code"
     end
     def self.down
     
     end

end