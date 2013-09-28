class ModSchool < ActiveRecord::Migration
     def self.up        
        add_column "schools",:closed,:boolean     
        School.update_all("closed = 0")
        School.reset_column_information
     end
     def self.down
            remove_column "schools",:closed            
     end

end