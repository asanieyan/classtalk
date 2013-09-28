module ClassTalk
  module FieldTextSanitizer
      def size_of(attr)
          self.class.size_of(attr)
      end
      alias length_of size_of
      
      class ActiveRecordTextHelper
          extend  ActionView::Helpers::TagHelper
          extend  ActionView::Helpers::TextHelper                           
      end
      #before validate it will one of the following
      #truncate
      #strip_tags
      #escape_once
      #sanitize_html
      #and the combination of trucate and sanitize_html escape_once strip_tags
      def self.included(base)      
           class << base                            
                def size_of(attr)
                   columns_hash[attr].limit
                end
                alias length_of size_of
                alias values_of size_of
                def before_validate_iterate_for(*attrs)
                  attrs.flatten!
                  options = {:remove_whitespace=>false}.update(attrs.last.is_a?(Hash) ? attrs.pop : {})                  
                  attrs.map!{|a| a.to_s}
                  before_validation do |post|                                 
                      attrs.each do |attr|                                    
                          raise Exception, "Invalid attribute #{attr} for #{self}" unless column_names.include?(attr)                   
                          post[attr] = yield(attr,post[attr])
                          post[attr] = post[attr].strip                         
                          post[attr].gsub!(/\s+/,' ') if options[:remove_whitespace]
                      end                    
                   end              
                end
                def truncate(*attrs)                
                    before_validate_iterate_for(attrs) do |attr,attr_value|                     
                       ActiveRecordTextHelper::truncate(attr_value || "",size_of(attr),"")
                    end
                end
                def escape_once(*attrs)
                    before_validate_iterate_for(attrs) do |attr,attr_value|                       
                          ActiveRecordTextHelper::escape_once(attr_value || "")                                           
                    end
                end
                def strip_tags(*attrs)
                    before_validate_iterate_for(attrs) do |attr,attr_value|
                          ActiveRecordTextHelper::strip_tags(attr_value || "")
                    end
                end
                def sanitize_html *attrs  
                    
                    added_tags = attrs.last.is_a?(Hash) ? attrs.pop.shift : ["style"]  
                    unless added_tags.empty?
                      ActionView::Helpers::TextHelper.const_set "VERBOTEN_TAGS", 
                          (ActionView::Helpers::TextHelper::VERBOTEN_TAGS + added_tags).flatten.uniq                                       
                    end
                    before_validate_iterate_for(attrs) do |attr,attr_value|
                        sant = ActiveRecordTextHelper::sanitize(attr_value || "")
                    end              
                end
               
            end
            base.class_eval do
                def self
                    return base
                end
            end
            %w(strip_tags sanitize_html escape_once).each do |method|                           
                base.class_eval <<-"end_eval"                                  
                    def self.#{method}_and_truncate (*args)
                        #{method}(args)
                        truncate(args)
                    end                  
                end_eval
            end
           
      end
  end  
  module Reportable
      def self.included(base)
        base.extend(ClassMethods)
      end
      module ClassMethods
          def acts_as_reportable *subjects
             options = subjects.last.is_a?(Hash) ? subjects.pop : {}
             subjects = subjects.empty? ? nil : subjects
             @report_subjects = subjects ||  (raise "You need to specify at least one report subject for #{self} Object")
             @reported_item_owner = options[:owner] || (raise "You must specifiy an owner of type user for #{self} Object")  #must return a user class
             @report_title = options[:title] || "'Report'"
             include ClassTalk::Reportable::InstanceMethods 
             has_many :reports, :as => :reportable
          end
      end
      module InstanceMethods
          def can_report?(reporter)
             raise "You must implement can report method"
          end
          def url reporter=nil
             (raise "You must provide a url for when the user clicks cancel")             
          end
          def owner              
              instance_eval(self.class.instance_variable_get("@reported_item_owner"))
          end
          def report_title
              instance_eval('"' + self.class.instance_variable_get("@report_title") + '"')
          end
          def report_subjects
              self.class.instance_variable_get("@report_subjects")
          end
      end
  end
end