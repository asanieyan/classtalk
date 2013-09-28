class TestController < PluginController
    def index
      session['persona_id'] = nil
    end
    def take_on      
      session['persona_id'] = User.find(params[:uid]).id
      fb_redirect_to :controller=>"profile"
    end
    private 
      def authorize_user
        true
      end
end