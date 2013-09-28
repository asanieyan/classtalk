class Course < CachedModel #ActiveRecord::Base
  belongs_to :school
  belongs_to :subject
  has_many :user_records,:class_name=>"KlassesUsers"
  has_many :klasses
  escape_once_and_truncate 'number','name','description'
  
  def before_save
    %w(number name description).each do |e| 
          self[e] = self[e].to_s.gsub(/&nbsp;/i,' ').gsub(/&amp;/i,'&').gsub(/&gt;/i,'>').gsub(/&lt;/i,'<').gsub(/&#145;/,"'").gsub(/&#146;/,"'").gsub(/&#147;/,'"').gsub(/&#148;/,'"')
    end
    self.number = self.number.gsub(/\s+/,'').strip
    self.credit = self.credit.to_f
    self.name = self.name.gsub(/\s+/,' ').strip.titlecase 
   
    #@TODO must have pretty name
    self['name'] = self['name'].titlecase
    %w(in but of the and at to or).each do |c|
      self['name'] = self['name'].gsub(/ #{c} /i," " + c.downcase + " ")
    end
    %w(I II III IV V VI).each do |c|
      self['name'] = self['name'].gsub(/ #{c} /i," " + c.upcase + " ")
    end
    self.description = self.description.gsub(/\s+/,' ').strip
    return self.number.size > 0
  end
  has_many :documents do 
      def tagged_with tags,*args
            @documents ||= find_tagged_with tags,*args
      end
  end
  #TODO find a use for these not being used anywhere
  has_many :classes , :class_name=>"Klass" do 
    #find all the classed of the course in the current semester
    def at(semester)
        @s ||= {}
        @s[semester.id] ||= self.find(:all,:conditions=>"status LIKE 'approved' AND semester_id = #{semester.id} AND course_id = #{proxy_owner.id}")
    end
    def current      
      return [] if proxy_owner.school.current_semesters.empty?
      @current_classes ||= self.find(:all,:conditions=>"status LIKE 'approved' AND semester_id IN (#{proxy_owner.school.current_semesters.map(&:id).join(',')}) AND course_id = #{proxy_owner.id}") rescue []
    end
  end
  #returns the credit of the course
  #if the credit is zero it returns NIL if the credit is float it return the float
  #howver if the credit is like 3.0 it return 3 
  def credit
      cc = self['credit'].to_f || 0
      if cc.to_i == cc
          return cc.to_i
      else
          return cc
      end      
  end
  #return the  title of the course
  #two format full and short
  def title format=:full
      first_part =  self.subject_code + " " + self.number
      if self.credit > 0
          first_part << "-" + self.credit.to_s
      end      
      return  first_part + " " + self.name if format==:full
      return  first_part     
  end
  #helpers to return the title of the course
  def title_no_credit
        return self.subject_code + "-" + self.number + " " + self.name  
  end
  def stitle_no_credit
        return self.subject_code + "-" + self.number
  end
  def full_title;title(:full);end
  def short_title;title(:short);end 
end
