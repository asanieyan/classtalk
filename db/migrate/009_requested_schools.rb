class RequestedSchools < ActiveRecord::Migration
    def self.up
      create_table "requested_schools", :force => true do |t|
        t.column "nid", :integer, :default => 0, :null => false
        t.column "name", :string
        t.column "user_id", :integer
      end 
      add_index "requested_schools", ["nid", "name", "user_id"], :unique => true
    end
    def self.down
        drop_table :requested_schools
    end

end