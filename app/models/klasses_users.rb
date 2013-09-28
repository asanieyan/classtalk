class KlassesUsers < CachedModel #ActiveRecord::Base
    set_table_name "klasses_users"
    belongs_to :klass
    belongs_to :role
end
