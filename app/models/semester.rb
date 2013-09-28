class Semester < CachedModel #ActiveRecord::Base
    belongs_to :season
    has_many :klasses
    belongs_to :school  
    def name(with_year=true)
         sname = self.season.name 
         if with_year
           sname += " " + self.start_date.year.to_s    
         end
         return sname
    end
    def period(year=true)
        str = "%b %d"
        str += " %Y" if year
        self.start_date.strftime(str) + " - " + self.end_date.strftime(str)     
    end
    def is_current?
      Time.now.utc.to_date >= self.start_date.to_date && Time.now.utc.to_date <= self.end_date.to_date 
    end
end
class Season < CachedModel #ActiveRecord::Base
  has_many :semesters,:dependent=>:destroy 
  belongs_to :school
  acts_as_nested_set :scope=>:school
  
  def generate_calendar_year(base_year,ignore_duplicate=false)     
      sems = []
      self.root.full_set.each do |season|
         season.set_base_year(base_year)
         begin           
           sem = Semester.create(:season_id=>season.id,
                           :school_id=>season.school_id,
                           :start_date=>season.start_date,
                           :end_date=>season.end_date)
           sems << sem
           rescue Exception=>e
            ignore_duplicate ? next : (raise e)
         end
      end
      sems      
  end
  def set_base_year(base_time)
      @base_time = base_time
  end
  def get_root         
      @root ||= if self.new_record?
          self.school.seasons.find(:first).root 
      else
          self.root
      end
  end
  def calendar_year_start     
      now = @base_time || Time.now.utc
      if self.get_root.start_month > now.month or (self.get_root.start_month == now.month && self.get_root.start_day > now.day)
          #months have been reset due to new year
          #so the root was from last year
          year = now.year - 1
      else
          year = now.year 
      end  
      Time.utc(year,get_root.start_month,get_root.start_day)
  end
  def calendar_year_end
      calendar_year_start.next_year.ago(1.day)   
  end
  def start_date 
      if self.start_month < calendar_year_start.month or (self.start_month == calendar_year_start.month && self.start_day < calendar_year_start.day)
          year = calendar_year_start.year + 1
      else
          year = calendar_year_start.year
      end
      
      Time.utc(year,start_month,start_day)
  end  
  def end_date
      if end_month < start_date.month or (end_month == start_date.month && end_day <= start_date.day)
        puts end_day
        puts start_date.day
        year = start_date.year + 1
      else
        year = start_date.year
      end
      Time.utc(year,end_month,end_day)
  end   
  def calendar_period(include_year=false)
    str = "%b %d"
    str += " %Y" if include_year
    self.calendar_year_start.strftime(str) + " - " + self.calendar_year_end.strftime(str)      
  end
  def period(include_year=false)
    
    str = "%b %d"
    str += " %Y" if include_year
    self.start_date.strftime(str) + " - " + self.end_date.strftime(str)
  end  
  def is_current?   
     Time.now.utc.to_date >= start_date.to_date && Time.now.utc.to_date <= end_date.to_date
  end
  def before_save

      self['name'] = self['name'].gsub(/\s+/,' ').strip
      if  self.school.seasons.size == 0
        valid_date = true
      elsif !new_record? and self.root?
        valid_date = true    
      else
        puts "processing #{self.name} #{self.start_str}-#{self.end_str}"
        puts "calendar #{calendar_year_start.to_s}-#{calendar_year_end.to_s}"
        valid_date = self.start_date >= self.calendar_year_start &&
                        self.end_date <= self.calendar_year_end
      end
      raise "#{self.period(true)} is not within the calendar year #{calendar_period(true)}" unless valid_date
  end
  def validate
      errors.add_to_base "Invalid Semester" unless self['name'].to_s =~ /\w/ &&
      self['start_str'].to_s =~ /\d\d?\/\d\d?/ && 
      self['end_str'].to_s =~ /\d\d?\/\d\d?/
  end
  def start_month;self['start_str'].split("/")[0].to_i;end;
  def start_day;self['start_str'].split("/")[1].to_i;end;
  def end_month;self['end_str'].split("/")[0].to_i;end;
  def end_day;self['end_str'].split("/")[1].to_i;end;  
  
end

