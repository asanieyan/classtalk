Info = {
    :name=>"Michigan State University",
    :nid=>"16777240",
    :city=>"east lansing",
    :region=>"michigan",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/25"],
      ["Spring","1/1"],
      ["Summer I","5/12"],
      ["Summer II","7/1"],      

    ]
}          
class MichiganStateUniversityParser < CourseParser
    def start
        options = doc_at("http://www.reg.msu.edu/Courses/Search.asp").at("#Select1").search("option")
        options.shift;
        options.each do |option|
          s_code = option['value']
          s_name = option.inner_html.gsub(/#{s_code}/,'').strip
          subject = get_subject(s_code,s_name)
          ["1074"].each do |term|
            code = subject.code          
            doc = parse(post("http://www.reg.msu.edu/Courses/Request.asp","Term=#{term}&SubjectCode=#{code}&CourseNumber=&Submit1=+++++Search+++++"))
            doc.search("td.displaydataheading") do |td|
              if (td.inner_html.include?("Course") rescue next)
                  table = td.parent.parent
                  @desc  = @cc = @code = @number = @name = ""                                         
                    table.search("td.displaydataheading").each do |header|
                        begin
                          @parsing = ""
                          if header.inner_html == "Course:"
                            @parsing = "course"
                            inner = strip_tags(header.next_sibling.inner_html).split(" ",3)                  
                            @code,@number,@name=inner             
                          elsif header.inner_html == "Credits:"
                            @parsing = "credit"
                            cc = header.next_sibling.inner_html
                            @cc =  cc
                          elsif header.inner_html == "Description:"
                            @parsing = "description"
                            @desc = header.next_sibling.inner_html  
                          else
                            @parsing = header.inner_html
    #                         puts header.inner_html
                          end
                        rescue Exception=>e                      
                            next if strip_tags(header.inner_html).include?("View all versions of this course")
                            puts "while parsing #{@parsing} this happened"
                            puts e.message
                            puts "header content : "
                            puts header.inner_html
                            raise 
                        end                                                              
                    end
                  next if @number == ""
                  subject.get_course(@number,@name,@desc,@cc,:code=>@code)
              end
            end

#              course_td.at("tbody").search("tr").each do |row|         
#                  header,value = row.search("td")
#                  if header.inner_html =~ /Course/
#                    inner = strip_tags(header.next_sibling.inner_html).split(" ",3)                  
#                    @code,@number,@name=inner             
#                  elsif header.inner_html =~ /Credit/
#                    @cc =  header.next_sibling.inner_html
#                  elsif header.inner_html =~ /Description/
#                    @desc = header.next_sibling.inner_html
#                  end                                   
#              end              
#              subject.get_course(@number,@name,@desc,@cc,:code=>@code)                              
#              course_row = course_row.next_sibling

          end
        end
    end
end
