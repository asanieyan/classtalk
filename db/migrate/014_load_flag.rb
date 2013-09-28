class LoadFlag < ActiveRecord::Migration
    def self.up
      add_column :schools,:loaded,:boolean,:default=>false
      School.find(:all).each do |school|
          school.update_attribute("loaded",true)
      end
      
    end
    def self.down
      remove_column :schools,:loaded
    end
end