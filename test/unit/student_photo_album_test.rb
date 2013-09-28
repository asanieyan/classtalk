require File.dirname(__FILE__) + '/../test_helper'

class StudentPhotoAlbumTest < Test::Unit::TestCase
  fixtures :student_photo_albums

  # Replace this with your real tests.

  def test_save_photos
    params = {:id=>"816717565610925385",:upload_files=>{"f1"=>uploaded_file("c:/temp/m.zip")}}
    

  end
end
