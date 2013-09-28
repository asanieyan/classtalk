class Settings < ActiveRecord::Migration
    def self.up
      create_table "settings", :force => true do |t|
        t.column "user_id", :integer, :default => 0, :null => false
        t.column "name", :string
        t.column "context_id", :integer, :default => 0, :null => false
        t.column "context_type", :string
        t.column "bool_val", :boolean
        t.column "val", :string
      end
      add_index "settings",["user_id","name","context_type","context_id"],:unique=>true
      %w(start_day start_month end_day end_month season_index).each do |col|
          remove_column :seasons,col rescue puts "#{col} doesn't exists"
      end
      %w(next_sem_id pre_sem_id).each do |col|
         remove_column :semesters,col rescue puts "#{col} doesn't exists"
      end
      remove_column :document_files,"data"      
    end
    def self.down
        drop_table "settings"
    end
end