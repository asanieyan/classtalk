class PluginController < ApplicationController
#  include all the plugins 
  #no method should be here as this is the parent controller for all the plugins
  before_filter :authorize_use_of_plugin_by_user
  #a short cut to skip authentication for a plugin
  @@skip_plugin_auth = {}
  def self.skip_big_filters options
     options.symbolize_keys!
     [:only,:except].each do |k|
       if options[k] != nil
         @@skip_plugin_auth[k] ||= []
         @@skip_plugin_auth[k] += [options[k]].flatten
         @@skip_plugin_auth[k].uniq!
       else
        @@skip_plugin_auth[k] = nil
       end

     end        
     #need to use the dup
     #because the it will change the hash
     skip_before_filter :update_affiliations,:authorize_use_of_plugin_by_user,@@skip_plugin_auth.dup
     
  end
  private
    def authorize_user
      return true
    end
    def authorize_use_of_plugin_by_user       
        
        if authorize_user
          return true
        else  
          render :text=>"You don't have access to this part"
        end
    end
    
    
end