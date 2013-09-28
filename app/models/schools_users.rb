class SchoolsUsers < CachedModel #ActiveRecord::Base
  set_table_name "schools_users"
  belongs_to :user
  belongs_to :school
  belongs_to :role
  def before_create
    self.account_status = :activated
  end
end