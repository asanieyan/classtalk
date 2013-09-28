class Subject < CachedModel #ActiveRecord::Base
    has_many :courses ,:order=>"CAST(number AS SIGNED) ASC",:conditions=>"status LIKE 'approved' OR status LIKE 'pending'"
    belongs_to :school
    escape_once_and_truncate 'code','name'
    def before_save
        ['name','code'].each do |e| 
           self[e] = self[e].to_s.gsub(/&nbsp;/i,' ').gsub(/&amp;/i,'&').gsub(/&gt;/i,'>').gsub(/&lt;/i,'<').gsub(/&#145;/,"'").gsub(/&#146;/,"'").gsub(/&#147;/,'"').gsub(/&#148;/,'"')
        end
        self.code = self['code'].upcase.gsub(/\s+/,' ').strip.upcase
        self['name'] = self['name'].gsub(/\s+/,' ').strip
        self['name'] = self['name'].titlecase
        %w(in but of the and at to).each do |c|
          self['name'] = self['name'].gsub(/ #{c} /i," " + c.downcase + " ")
        end
        return  self.code.size > 1        
    end
    def name
        if self['name'].to_s.size == 0
          return self['code']
        else
          return self['code'] + " - " + self['name']
        end
    end
end