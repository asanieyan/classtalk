Info = {
    :name=>"Penn State",
    :nid=>"16777310",
    :city=>"",
    :region=>"pennsylvania",    
    :country=>"united_states",
    :semesters=>[
      ["Fall","8/20"],
      ["Spring","1/1"],
      ["Summer 1st Session","5/15"],            
      ["Summer 2nd Session","7/1"],            
    ]
}      
class PennStateParser < CourseParser

    def initialize(parse)
        @no_courses = {}
        @missing_courses = []
        @unprocessable = []   
        super(parse)   
        print_result  
    end
    def start1
        url = "http://www.psu.edu/bulletins/whitebook/courses/marsc.htm"
        doc = parse(get(url))        
        subject = normal_subjet_parsing(doc)
        ps = doc.search("p")
        ps.shift;
        ps[0..14].each_with_index do |mini,i|
            c_num = i + 1
            c_name = mini.at("b").inner_html
            c_desc = mini.inner_html.gsub(/#{mini.at("b")}/,'').gsub(/\s+/,' ').strip                  
            if c_desc.match(/^\(.*?\)/)
                c_c = c_desc.slice!(/^\(.*?\)/).gsub(/\(|\)/,'')      
            else
                c_c = 0
            end
            subject.get_course(c_num,c_name,c_desc,c_c)                          
        end
        if subject.courses.size == 0
          @no_courses[subject] = true
        elsif @no_courses[subject]
          @no_courses.delete(subject)
        end        
    end
    def start
      url1 = "http://www.psu.edu/bulletins/bluebook/"
      url2 = "http://www.psu.edu/bulletins/whitebook/"
      [url1 + "co.htm" ,url2 + "courselist.htm"].each do |url|                  
          parse(get(url)).search("a[@href^='courses']").each do |link|
              next_url = (url + "/../" + link['href'])
              
              doc = parse(get(next_url))
              title = doc.at("h1").inner_html
              begin  
                s_name = title.slice!(/[^(]+/).strip 
                title.slice!(0)
                s_code = title.slice!(/[^)]+/).strip
              rescue
                puts "can't process #{next_url}"
                @unprocessable << next_url
                next
              end              
              subject = get_subject(s_code,s_name)
              doc.search("p").each do |p|
                normal_course_parsing(subject,p)
              end
#              normal_course_parsing(subject,doc.at("p"))
              if subject.courses.size == 0
                @no_courses[subject] = true
              elsif @no_courses[subject]
                @no_courses.delete(subject)
              end
          end
      end
      start1   
    end
    def print_result
      puts "printing report"
      puts "these subject didn't have any courses"
      @no_courses.each do |subject|
        puts subject.to_s
      end
      puts "couldn't parse"
      @missing_courses.each do |c|          
          puts c
      end    
    end
    def normal_subjet_parsing doc      
      title = doc.at("h1").inner_html
      begin  
        s_name = title.slice!(/[^(]+/).strip 
        title.slice!(0)
        s_code = title.slice!(/[^)]+/).strip
      rescue
        puts "can't process #{next_url}"       
        next
      end
#              next unless s_code == "CMPSC"
      subject = get_subject(s_code,s_name)              
    end    
    def normal_course_parsing subject,html,options={}
      courses = html.inner_html.split(/<br \/>\s+<br \/>/)
      courses.pop
      courses.each do |course|
          begin
          mini = parse(course)
          c_link = mini.at("a[@href*='htm']")
          c_num = c_link.inner_html.gsub(/#{subject.code}/,'').strip
          while c_link.next_node.text? do
            c_link.next_node
            c_link.next_node.swap("")
          end 
          c_name_html = Regexp.escape(c_link.next_sibling.to_html)
          c_name = c_link.next_sibling.inner_html
          c_link_html = Regexp.escape(c_link.to_html)
          c_desc = mini.inner_html.gsub(/#{c_link_html}/,'').gsub(/#{c_name_html}/,'').gsub(/\s+/,' ').strip 
          if c_desc.match(/^\s*\(.*?\)/)
              desc = c_desc[c_desc.index(")")+1,c_desc.size]
              c_c  = c_desc[0,c_desc.index(")")+1]
              c_desc = desc
          else
              c_c = 0
          end
          subject.get_course(c_num,c_name,c_desc,c_c)
          rescue Exception=>e
            c_num rescue c_num = nil  
            c_name rescue c_name = nil                                     
            puts c_name
            @missing_courses << [subject.code,c_num,c_name] 
            p "can't do this"
            p e.message
            p @missing_courses.last
            next
          end
          
      end        
    end
    def start0
      [
      "http://www.psu.edu/bulletins/bluebook/courses/acctg.htm"
#      "http://www.psu.edu/bulletins/bluebook/courses/micrb.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/micrb.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/music.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/music.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/air.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/air.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/latin.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/latin.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/wildl.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/wildl.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/greek.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/greek.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/kines.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/kines.htm",      
#      "http://www.psu.edu/bulletins/whitebook/courses/math.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/math.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/mktg.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/mktg.htm",
#      "http://www.psu.edu/bulletins/whitebook/courses/geosc.htm",
#      "http://www.psu.edu/bulletins/bluebook/courses/geosc.htm"
      ].each do |url|
          doc = parse(get(url))
          subject = normal_subjet_parsing(doc) 
          doc.search("p").each do |p|
            normal_course_parsing(subject,p)
          end
      
      end
    end
    def start3
       ["http://www.psu.edu/bulletins/bluebook/courses/soc.htm",
        "http://www.psu.edu/bulletins/whitebook/courses/soc.htm",
        "http://www.psu.edu/bulletins/whitebook/courses/phil.htm",
        "http://www.psu.edu/bulletins/bluebook/courses/phil.htm"].each do |url|
          doc = parse(get(url))
          subject = normal_subjet_parsing(doc) 
          courses = normal_course_parsing(subject,doc.search("p")[1])
       end
    end    
end
