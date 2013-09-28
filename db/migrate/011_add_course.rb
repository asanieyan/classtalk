class AddCourse < ActiveRecord::Migration
     def self.up
        
        add_column "subjects",:creator_id, :integer
        add_column "subjects",:status,:enum,:limit=>["pending","approved","rejected","retiered"]
        add_column "subjects","created_on",:date  
        add_column "subjects","updated_on",:date 
        
        add_column "courses",:creator_id, :integer
        add_column "courses",:status,:enum,:limit=>["pending","approved","rejected","retiered"]
        add_column "courses","created_on",:date  
        add_column "courses","updated_on",:date 
        
        add_column "klasses",:created_on,:date
        add_column "klasses",:updated_on,:date
        add_column "klasses",:creator_id,:integer
        add_column "klasses",:status,:enum,:limit=>["pending","approved","rejected"]
        add_column "klasses",:section,:string,:limit=>15

        Subject.update_all("status = 'approved'")
        Course.update_all("status = 'approved'")
        Klass.update_all("status = 'approved'")

        Klass.reset_column_information
        Subject.reset_column_information
        Course.reset_column_information
     end
     def self.down
            remove_column "courses",:creator_id
            remove_column "courses",:status
            remove_column "courses","created_on"
            remove_column "courses","updated_on"
                       
            remove_column "subjects",:creator_id
            remove_column "subjects",:status
            remove_column "subjects","created_on"
            remove_column "subjects","updated_on"
                        
            [:created_on,:updated_on,:creator_id,:status,:section].each do |col|
                remove_column "klasses",col 
            end    
            
     end

end