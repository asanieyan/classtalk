class Invites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.column :inviter_id,:integer,:null => false
      t.column :invitee_id,:integer
      t.column :klass_id,:integer
      t.column :invite_type,:string,:limit=>20
      t.column :app_user,:enum,:limit=>[:y]
      t.column :fb_user,:enum,:limit=>[:y]
      t.column :name,:string,:limit=>100
      t.column :email,:string,:limit=>100
      t.column :updated_on, :datetime
    end
    add_index :invites,[:inviter_id,:invitee_id,:invite_type],:uniq=>true        
  end
  def self.down
   drop_table :invites
  end


end