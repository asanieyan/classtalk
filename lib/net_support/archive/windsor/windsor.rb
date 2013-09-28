Info = {
    :name=>"Windsor",
    :nid=>"16778444",
    :city=>"windsor",
    :region=>"ontario",    
    :country=>"canada",
    :semesters=>[

  ["Fall","9/1", "12/25"],
  ["Winter","1/7", "4/25"],  
  ["Intersession","5/12", "6/22"],
  ["Summer","7/3", "8/25"],  
  ["12WK Session","5/12", "8/25"] 
  

    ]
}          
class WindsorParser < CourseParser
    def parse_course(c_elm)
        c = normalize(c_elm.inner_text)
        cnumbers = c.slice!(/[^A-Z.]+/)
        cname = c
        cname.sub!(/\./,'')
        cnumbers = cnumbers.delete(".")
        courses = []
        @scode = nil
        cnumbers.split(/,|and/).each do |cnum|
          if cnum =~ /to/
              @has_range = true
              puts "has range"
          end
          range_courses = cnum.split("to")
          range_courses = range_courses.map{ |cnum|             
             cnum = normalize(cnum)
             if cnum =~ /\d\d-?\d\d\d/
                 @scode = cnum.slice!(/^\d\d/)
                 scode = @scode
                 cnum = cnum.delete("-")
             elsif cnum =~ /^\d\d\d$/ and @scode                 
                 scode = @scode
             else
                puts cnumbers
                raise "weird shit"
             end
             if scode.to_s.size == 0 or cnum.to_s.size == 0
              nil
             else
              [scode,cnum]
             end
           }.compact
           prompt range_courses if @has_range
           if range_courses.size > 2
              raise "more than two element"
           elsif range_courses.size == 1
              scode,cnum = range_courses.shift
              courses << [scode,cnum,cname] 
           elsif range_courses.size == 2
              @has_range = false
              scode1,cnum1 = range_courses.shift;
              scode2,cnum2 = range_courses.shift;
              raise "not same range subject" if scode1 != scode2
              puts "start range"
              (cnum1.strip.to_i..cnum2.strip.to_i).to_a.each do |i|
                puts scode1 + " " + i.to_s
                courses << [scode1,i.to_s,cname]       
              end
              prompt "end range"
           else
              
           end           
        end
        cdesc = c_elm.next_node
        while cdesc && cdesc.pathname != "font"           
            if !cdesc or cdesc.pathname == "b"
                cdesc = nil
            else
                cdesc = cdesc.next_node
            end           
        end        
        cdesc = cdesc ? normalize(cdesc.inner_text) : ""
        courses.map!{|c| c << cdesc}        
    end

    def start
      links =  [
                "http://web4.uwindsor.ca/units/registrar/calendars/graduate/cur.nsf/SubCategoryFlyOut/D8BDC9BA5760F098852572D000516CA0",
                "http://web4.uwindsor.ca/units/registrar/calendars/undergraduate/Fall2007.nsf/SubCategoryFlyOut/7E4EDF63A9990D72852572C80056F592"
      ]
      departs = []
      links.each do |link|
          doc = doc_at(link)
          departs += doc.search('a[@target="RIGHT"]')  + doc.search('a[@target="right"]')          
      end
      departs.map!{|d| 
        subjects = d.next_node
        while subjects.inner_text !~ /xxx/ do
           subjects = subjects.next_node
        end
        subjects = subjects.inner_text.slice(/\(\d\d-xxx.*/).delete(")(x-").split(", ")
#        subjects = normalize(subjects.inner_text)
#        p subjects if subjects.size == 1
        [d,subjects]
      }
#      departs = departs.select{|l,s| s.include?("80")}
      set_s_name "98"=>"Law",
                 "99"=>"Law",
                 "27"=>"Studio",
                 "28"=>"Art History",
                 "01"=>"General Arts and Social Sciences",
                 "02"=>"General Arts and Social Sciences",
                 "48"=>"SOCIOLOGY/CRIMINOLOGY",
                 "76"=>"M.B.A.",
                 "77"=>"M.B.A FOR MANAGERS AND PROFESSIONALS",
                 "78"=>"MASTER OF MANAGEMENT",
                 "80"=>"Education",
                 "81"=>"Education",
                 "82"=>"Education",
                 "62"=>"MATHEMATICS",
                 "65"=>"STATISTICS",
                 "61"=>"Geology",
                 "85"=>"General Enigeering",
                 "26"=>"English, Language, Literature and Creative Writing"
      courses = {}
      departs.each do |link,subjects|          
      begin
          if subjects.size == 1 or subjects.include?("98") || 
                                   subjects.include?("27") || 
                                   subjects.include?("01")              
              
              
              subjects.each_with_index do |subject,i|
                  sname = nil                 
                  if subjects.size == 1
                    sname = link.inner_text
                    sname = sname.split(" - ")[1] if sname =~ /Engineering/
                  end
                  scode = subjects[i]
                  get_subject(scode,sname)
              end
              subjects = []
          end 
 
          subject_names = []
          course_doc = doc_at(link['href'])
          course_doc.search("div#tplLeftDiv").remove          
          course_doc.search("b").each do |b|
              if normalize(b.inner_text) =~ /^\d\d-\d\d\d/
                   parse_course(b).each do |scode,cnum,cname,cdesc|
                     courses[scode] ||= []
                     puts "course #{scode}:#{cnum}" 
                     if  cnum.strip !~ /^\d\d\d$/
                         puts "#{cname}"
                         cnum = prompt "enter course  number"
                         puts "course #{scode}:#{cnum}"                                                   
                     end
                     courses[scode] << [cnum,cname,cdesc]                  

                     
                   end                  
              elsif subjects.size > 1 && (b.inner_html =~ /<i>/ || 
                                normalize(b.inner_text) =~ /^[A-Z]{2}( [A-Z]{2})?/ && 
                                b.inner_text !~ /COURSES/)
                #get subjects first
                subject_names << b.inner_text
                first_course = b.next_node
                while normalize(first_course.inner_text) !~  /^\d\d-\d\d\d/ do 
                      first_course = first_course.next_node
                end
                scode = parse_course(first_course).first.shift
                get_subject(scode,b.inner_text)
              end          
          end
#          if subjects.size > 1          
#                p subjects
#                puts subject_names.size 
#                puts subjects.size
#                puts "***************************************************"
#          end
      rescue Exception=>e
          prompt e.message
      end
      end
      
      courses.each do |s_code,courses|
          subject = get_subject(s_code)
          courses.each do |cnum,cname,cdesc|
             cnum = cnum.delete(".")
             subject.get_course(cnum,cname,cdesc)
          end
      end
   end
end
