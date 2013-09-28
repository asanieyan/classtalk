require File.dirname(__FILE__) + '/../test_helper'
require 'my_controller'

# Re-raise errors caught by the controller.
class MyController; def rescue_action(e) raise e end; end

class MyControllerTest < Test::Unit::TestCase
  def setup
    @controller = MyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)   
    FileUtils.copy_file(path,t.path)
    #  puts t.size
    #  puts t.read.size
    #  t.pos = 0
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  # Replace this with your real tests.
  def test_save_photos     
#     album =  StudentPhotoAlbum.find_by_guid(313764409611785162)
#     me = Student.find(1)
#     album.save_photos({:upload_files=>{:f1=>uploaded_file('c:/temp/3.zip','image/png')}},me)
     @request.session['student'] = 1     
     post :add_more_files_to_album, :id=>'313764409611785162',:upload_files=>{:f1=>uploaded_file('c:/temp/313.zip')}
  end
end
