class DefaultSeason < ActiveRecord::Migration
    def self.up
        add_column :schools,:sem_loaded,:boolean,:default=>false
        add_column :seasons,:deleted,:boolean,:default=>false
        add_column :semesters,:deleted,:boolean,:default=>false
        School.find(:all).each do |school|
            school.update_attribute(:sem_loaded,true)
        end        
    end
    def self.down
        remove_column :schools,:sem_loaded
        remove_column :seasons,:deleted
        remove_column :semesters,:deleted
    end
end