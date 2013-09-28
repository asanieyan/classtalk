class Notifier < ActionMailer::Base   
   Host =  ENV['RAILS_ENV'] == "production" ? "http://www.oycas.com"  : "http://dev.oycas.com:3000" 
   def a_message to,from,subject,msg_body
     @recipients = to
     @content_type = "text/html"
     @from       = from
     @subject    = subject     
     @body =  {'msg_body'=>msg_body}      
   end
end
