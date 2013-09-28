class Invite < ActiveRecord::Base
    def self.check_invited(inviter,invitee,type)
          Invite.find(:first,:conditions=>"invitee_id = #{invitee.to_i} AND invite_type LIKE '#{type}' AND inviter_id = #{inviter}")      
    end
end