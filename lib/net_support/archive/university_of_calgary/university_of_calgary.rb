Info = {
    :name=>"University of Calgary",
    :nid=>"16778423",
    :city=>"calgary",
    :region=>"alberta",    
    :country=>"canada",
    :semesters=>[
      ["Fall Session","9/1"],
      ["Winter Session","1/1"],
      ["Spring Session","5/1"],
      ["Summer Session","7/1"]
    ]
}          
class UniversityOfCalgaryParser < CourseParser
    def start
      
      parse(get("http://www.ucalgary.ca/pubs/calendar/2007/what/courses/subject.htm")).search("div[@class='alpha_section']").each do |alpha_section|
      
        alpha_section.search("li").each do |list_item|
       
          s_name = list_item.inner_html.sub(/(.*)<a(.*\n?)*/,'\1')
          s_code = list_item.inner_html[/\(.{3,4}\)/].gsub(/[\(\)]/,'')
  
          xsubject = get_subject(s_code,s_name)

          parse(get("http://www.ucalgary.ca/pubs/calendar/2007/what/courses/#{s_code}.htm")).search("div[@class='course']").each do |course|
          
            c_name = course.at("h4[@class='course_title']").inner_html rescue ""
            c_number = course.at("span[@class='course_number']").inner_html.gsub(/\D/,'') rescue 0
            c_description = course.at("p[@class='course_description']").inner_html rescue ""
            c_credits = 0#course.at("span[@class='course_hours']").inner_html[/\([^\(\)]*\)/].sub(/\((\d?\.?\d*).*\)/,'\1') rescue 0

            puts c_credits

            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            
          end

        end
      end
      
    end
end
