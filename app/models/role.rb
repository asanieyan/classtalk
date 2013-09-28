class RoleMapper
  #takes care of transferring facebook status to classtalk role and vice versa
  FacebookStatusToPrimaryRole = {
     ["undergrad","graduate"] => "student"
  }
  def self.fb_to_ct fb_status
      case fb_status.downcase
        when "undergrad","grad student";"student"
        when "faculty";"instructor"
        when "alumnus/alumna";"alumna"
        else "staff";"staff"
      end    
  end
  def self.ct_to_fb classtalk_role_str
      case classtalk_role_str.downcase
        when "student";["undergrad student","graduate student"]
        when "instructor";["faculty"]
        when "alumna";["Alumnus/Alumna"]
        else ["staff"]
      end     
  end
end
class Role < CachedModel #ActiveRecord::Base   
  acts_as_nested_set  
  Student = "student"
  Instructor = "instructor"
  def primary
    self['parent_id'] ? self.parent : self
  end
  def self.get role_string
    self.find(:first,:conditions=>[" name LIKE ?",role_string])
  end  
  def is? *roles      
      roles.include?(self.name)
  end
  def in_facebook
    RoleMapper::ct_to_fb(self.name)
  end
end
#class PluginsRole < ActiveRecord::Base
#  
#end