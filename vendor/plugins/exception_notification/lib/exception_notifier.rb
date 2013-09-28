require 'pathname'

class ExceptionNotifier < ActionMailer::Base
  @@sender_address = %("Exception Notifier" <exception.notifier@default.com>)
  cattr_accessor :sender_address

  @@exception_recipients = []
  cattr_accessor :exception_recipients

  @@email_prefix = "[ERROR] "
  cattr_accessor :email_prefix

  @@sections = %w(request userdetails session environment backtrace)
  cattr_accessor :sections

  def exception_notification(exception, controller, request, data={})
    subject    "#{email_prefix}#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}"

    recipients exception_recipients
    from       sender_address

    body       data.merge({ :controller => controller, :request => request,
                  :exception => exception, :host => request.env["HTTP_HOST"],
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :data => data,
                  :sections => sections })
  end

  private

    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      return @rails_root if @rails_root
      @rails_root = Pathname.new(RAILS_ROOT).cleanpath.to_s
    end

end

ExceptionNotifier.template_root = "#{File.dirname(__FILE__)}/../views"
