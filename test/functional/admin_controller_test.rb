require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.

  def test_wrong_admin_login
       post :login, :email=>'asanieya@sfu.ca'
       assert_redirected_to :controller=>'access',:action=>'login'
  end
  def test_right_admin_login
  
        assert true
  end
end
