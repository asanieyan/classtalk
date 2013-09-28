class StatusChangeNotice < ActiveRecord::Base
  belongs_to :user
  belongs_to :school
  belongs_to :old_role ,:class_name=>"Role",:foreign_key=>"old_role_id"
  belongs_to :new_role ,:class_name=>"Role",:foreign_key=>"new_role_id"
  strip_tags_and_truncate 'user_comment'

end