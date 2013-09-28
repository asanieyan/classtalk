# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class NotifyMailerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
     type = args.shift.to_s
     method = "#{type}_notifier".to_sym
     self.send method,args if self.respond_to?(method.to_s)    
  end
  def new_note_notifier args
          note = CourseNote.find(args.shift)
          klasses = note.klass ? [note.klass] : note.course.klasses_at_current_semester
          klasses.each do |klass|
           klass.students.select{|student| 
              ret_val = student.note_upload_notification != nil && student != note.owner
#              p "checking student #{student.full_name} #{ret_val}"
              ret_val
           }.each do |student|
                begin
                  Notifier::deliver_new_note_created(note,klass,student)
                rescue Exception=>e
#                  p e.message
                end
              end                
          end                    
  end
  def new_class_discussion_notifier args
       klass = Klass.find(args.shift)
       discussion = Forum.find(args.shift)
       klass.students.select{|student| student.class_discussion_notification && student != discussion.creator}.each do |recipient|               
           Notifier::deliver_new_topic_created(klass,discussion,recipient)
       end    
  end

end
NotifyMailerWorker.register
