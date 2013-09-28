class ReportController < PluginController
  #PARAM t: type of the object to be reported 
  #      id: id of the object to be reported
  def index
      reportable_class = params[:t].to_s.titlecase
      back_url = "/report?t=#{params[:t]}&id=#{params[:id]}"
      @reported_object = reportable_class.constantize().find(params[:id]) rescue render_return
      #TODO can logged_in_user report on this item why don't you ask the item itself
      # "#{logged_in_user.id} can't report on #{@reported_object.class} with id = #{@reported_object.id}" 
      render_return if @reported_object.owner == logged_in_user || 
                       !@reported_object.can_report?(logged_in_user) ||
                       logged_in_user.is_admin?
     
      if params[:commit]
        if params[:rs].to_i == -1
            r_msg "error",:title=>"Please provide a reason for this report of offensive content."
            return_after :fb_redirect_to ,back_url
              
          end
          report = Report.new(:reporter_id=>logged_in_user.id,
                                      :user_id=>@reported_object.owner.id,
                                      :resolved=>false,
                                      :subject=>(@reported_object.report_subjects[params[:rs].to_i] || render_return),
                                      :body=>params[:comment]
                                      )               
          unless report.valid?
              r_msg "error",:title=>report.errors.on('body')
              flash[:comment] = report.body
              flash[:rs] = params[:rs]
              return_after :fb_redirect_to ,back_url              
          end
          report.save
          @reported_object.reports << report
          return_after :fb_redirect_to ,@reported_object.url
    end

      
  end    

end