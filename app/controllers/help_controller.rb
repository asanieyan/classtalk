class HelpController < ApplicationController
  skip_before_filter :authenticate,:except=>"null"
  skip_before_filter :update_affiliations,:except=>"null"
  def index
      fb_redirect_to :action=>'main'
  end 
  def main

      begin

        @my_data = YAML.load_file("#{RAILS_ROOT}/lib/help_files/main_help.yml")
        #puts request.inspect

      rescue Exception => e

        #puts e

      end

  end

end
