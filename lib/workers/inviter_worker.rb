# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class InviterWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    args.shift == :facebook ? invite_from_facebook(args) : invite_from_email(args)
 
  end
  def invite_from_email(args)
    me = Student.find(args.shift)
    args.shift.each do |email|    
       Notifier::deliver_invite_to_oycas(me,email)
    end
  end
  def invite_from_facebook(args)
    require  File.join(RAILS_ROOT,'lib/facebookbot/init.rb')
    inviter_name = args.shift;
    username = args.shift;
    password = args.shift
    message = args.shift
    fb = FacebookBot.new({:email => username, :password => password})
    if !fb.logged_in?
      fail "Unable to login with the provided credentials!" 
    end  
    message = "come and check it out" if message.size == 0
     friends = fb.get_friends_in(School.find(:all).map{|s| s.facebook_domain})  
     friends.each do |friend|
        friend_name = friend.name.downcase.split(" ").first rescue friend.name.downcase 
        fb.send_message friend,"hey #{friend_name}, I'm on oycas.com",message           
        fb.wall_post friend,"hey #{friend_name}, I'm on oycas.com. come and check it out"     
   end
    
  end
end
InviterWorker.register
