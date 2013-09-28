require File.join(File.dirname(__FILE__),'protocol')
require 'rubygems'
require 'hpricot'
require 'yaml'

module ParserHelper
      def normalize(text)                 
         text1 = text.gsub(/&nbsp;/,' ').gsub(/\s+/,' ').strip   
         return text1
      end
      def remove_chars(text)
        String.new(text.gsub(/[^ -;:.A-Za-z0-9?!@#()&\/\\]/,''))
      end
      def html_decode(text)
        new_text = text
        new_text.gsub!(/&amp;/i,'&')
        new_text.gsub!(/&nbsp;/i,' ')
        new_text.gsub!(/&gt;/i,'>')
        new_text.gsub!(/&lt;/i,'<')   
        return   new_text
      end
      def strip_tags(html)
        html = html.to_s
        html = Hpricot(html).inner_text 
        html = html.gsub("&nbsp;"," ")
        html = html.gsub(/\s+/,' ')
        html = html.strip
        return html
        if html.index("<")       
          text = ""
          tokenizer = Hpricot(html)
          tokenizer.search("*").each do |node|             
            # result is only the content of any Text nodes

             text << node.to_s if node.text?
          end
          # strip any comments, and if they have a newline at the end (ie. line with
          # only a comment) strip that too
          text.gsub(/<!--(.*?)-->[\n]?/m, "") 
        else
          text = html# already plain text
        end 
        text.gsub!(/\s+/,' ')
        text.strip!
        return text
      end
end
class CourseParser
    
    include Protocol
    include ParserHelper
    class Semester
        def to_yaml
        
        end        
        def initialize(name,index,next_season,start_date,end_date)
            @name = name
            @index = index
            @next_season_name = next_season
            @start_date = start_date
            @end_date = end_date
        end 
    end
    class Subject    
        include ParserHelper
        attr_accessor :code, :name , :courses,:name_set
        def == subject
          self.to_s == subject.to_s
        end
        def to_s
            self.name + " " + self.code
        end
        def initialize code,subject_name
            @code = strip_tags(code)
            @name = strip_tags(subject_name)
            @courses = Array.new
            @name_set = false
        end
        def get_course number,name,desc="",credit="",options={}                                
              new_course = Course.new(options[:code] || self.code,number,name,desc,credit)
              c = @courses.detect {|c| c == new_course}
              if c 
                  puts "#{c.to_s} exists"       if $debug 
                  if c.credit < new_course.credit 
                    puts "updating credit"      if $debug 
                    c.credit = new_course.credit 
                  end
                  if new_course.desc.size > c.desc.size
                    c.description = new_course.desc 
                    puts "updating description"  if $debug 
                  end                  
              else                       
                 puts "creating course #{new_course.to_s}" if $debug  
                 @courses << new_course
                 c = new_course                         
              end
              return c                
        end

    end
    class Course
        include ParserHelper
        attr_accessor :name,:number,:description,:subject,:credit
         def == course
            self.subject + " " + self.number == course.subject + " " + course.number
         end         
         def to_s
            self.subject + " " + self.number + "-" + self.credit.to_s + " " + self.name
         end
         def initialize  subject, number,name, desc,credit                    
              @number = strip_tags(number).gsub(/\s+/,' ').strip 
              raise "#{subject}: the course number is empty" if @number == ""
              @name = strip_tags(name).gsub(/\s+/,' ').strip
              @description = strip_tags(desc).gsub(/\s+/,' ').strip
              @subject = strip_tags(subject).gsub(/\s+/,' ').strip
              @credit = strip_tags(credit)
              @credit.sub!(/[^\d\.]*(\d?\.?\d+){0,1}.*/,'\1')
              
         end
         def desc
            description
         end

    end
    def after_parse
    
    end
    def initialize
        @subjects = []
        @semesters = []
        @subject_names = {}
        @subject_codes = {}

    end
    def find_subject_by_code(code)
      code = code.gsub(/\s+/,' ').strip
#      puts "looking for subject with code = #{code}"
      subject = @subjects.find {|s| 
                      (s.code == code)
                  }
      if subject
#        puts "found #{subject.to_s}"
        return subject                    
      end
      
    end
    def set_s_name hash
        @subject_names = hash if hash
    end
    def set_s_code hash
        @subject_codes = hash if hash
    end
    def set_c_name hash
        @course_names = hash if hash
    end
    def get_subject code="",name="",options={}
                
        new_subject = Subject.new(code, name)        
        if new_subject.code == "" &&  new_subject.name != ""
              new_subject.code = @subject_codes[new_subject.name] || prompt("Enter code for #{new_subject.name}:")
              return if new_subject.code == "no subject"
        end
        if @subject_names[new_subject.code]
            new_subject.name = @subject_names[new_subject.code]
        end
        subject = find_subject_by_code(new_subject.code)
        if subject &&  subject.name.strip != new_subject.name.strip &&             
            new_subject.name.strip.size > 0 && !subject.name_set
            if @subject_names[new_subject.code]
              subject.name =  @subject_names[new_subject.code]
            elsif options[:select_old_name]
            
            elsif options[:select_new_name]           
              subject.name = new_subject.name
            else
              puts "subject.name:  " + subject.to_s
              puts "new_subject.name: " + new_subject.to_s            
              subject.name = prompt("Enter the name of the subject:").strip    
            end
            subject.name_set = true      
        end
        if options[:dont_add]        
            
        elsif (not subject)
            puts "creating subject #{new_subject.to_s}" if $debug || $sdebug
            if !@dont_ask_name && new_subject.name == ""
              new_name = prompt("Enter a name for #{new_subject.code} or press enter if you don't want to be asked anymore")
              new_name = new_name.gsub(/\s+/,' ').strip
              if new_name == "" 
                @dont_ask_name = true
              else
                new_subject.name = new_name 
              end
            end 
            @subjects << new_subject    
            subject = new_subject                                 
        else
            puts "subject #{subject.to_s} (#{subject.courses.size}) exists"
        end
        return subject
    end
    def doc_at(url)
        parse(get(url))
    end
    def parse(html)
        Hpricot(html)
    end 
    def start_parsing
        begin
          if File.exists?(result_file) and confirm("the result file already exists, load existing data first?")
              YAML::load_file(result_file)[:courses].each do |s|
                subject = get_subject(s[:code],s[:name])
                s[:courses].each do |course|
                    subject.get_course(course[:number],course[:name],course[:description],course[:credit])
                end
                
              end
          end
          start                    
        rescue Exception=>e
          puts "Exception Occured " + e.message
#          puts e.backtrace.join("\n")
          puts "Saving data..."
        end
    end   
    def start
      raise "Subclasses must implement this method"
    end
    def result_dir
      school = self.class.to_s.gsub('Parser','').underscore
      File.dirname(__FILE__)
    end
    def result_file 
      school = self.class.to_s.gsub('Parser','').underscore      
      if File.exists? File.dirname(__FILE__) + "/#{school}"
          File.dirname(__FILE__) + "/#{school}/#{school}.yml" 
      else
          File.dirname(__FILE__) + "/archive/#{school}/#{school}.yml" 
      end
    end
    def update_seasons
        pre_yaml = YAML::load_file(result_file)
        courses = pre_yaml[:courses]
        File.open(result_file, 'w' ) do |out|
           YAML.dump({:info=>Info,:courses=>courses}, out) 
        end      
    end
    def finalize
        t = Array.new
        @subjects.each do |subject|
              (_subject_ = {:name=>subject.name,:code=>subject.code})
              _subject_[:courses] = Array.new
              subject.courses.each do |course|              
                  _subject_[:courses] << {:subject=>course.subject,:name=>course.name,:description=>course.description,:number=>course.number,:credit=>course.credit}                         
              end
              t << _subject_
        end        
        File.open(result_file, 'w' ) do |out|
           YAML.dump({:info=>Info,:courses=>t}, out) 
        end        
    end
end