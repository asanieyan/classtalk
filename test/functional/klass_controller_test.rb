require File.dirname(__FILE__) + '/../test_helper'
require 'klass_controller'

# Re-raise errors caught by the controller.
class KlassController; def rescue_action(e) raise e end; end

class KlassControllerTest < Test::Unit::TestCase
  def setup
    @controller = KlassController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
