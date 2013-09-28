class Promotion < ActiveRecord::Migration
    def self.up
         create_table "promos", :force => true do |t|
            t.column "user_id", :integer, :default => 0, :null => false
            t.column "code", :string
            t.column "counter",:integer,:default=>0
        end 
        add_index :promos,["user_id"],:unique=>true
    end
    def self.down
        drop_table "promos"  
    end
end