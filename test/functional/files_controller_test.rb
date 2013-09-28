require File.dirname(__FILE__) + '/../test_helper'
require 'files_controller'

# Re-raise errors caught by the controller.
class FilesController; def rescue_action(e) raise e end; end

class FilesControllerTest < Test::Unit::TestCase
  def setup
    @controller = FilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  # Replace this with your real tests.
  def test_attach_file
#      post :upload, "note"=>{"title"=>"my note"}, "courseid"=>"806350272748085520",
#            "processor"=>{"id"=>"1000001"}, "success"=>"/course/806350272748085520/ACMA-320/share_notes", 
#            "upload_id"=>"1169944954", 
#            "failure"=>"/course/806350272748085520/ACMA-320/share_notes"
            
      post :upload, "noteid"=>"816717565610925385", "processor"=>{"id"=>"1000001"}
     
  end 
end
