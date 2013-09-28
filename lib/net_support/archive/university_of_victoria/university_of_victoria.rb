Info = {
    :name=>"University of Victoria",
    :nid=>"16778442",
    :city=>"victoria",
    :region=>"british columbia",    
    :country=>"canada",
    :semesters=>[
      ["Winter - 1st term","9/1"],
      ["Winter - 2nd term","1/1"],
      ["Summer","5/1"]
    ]
}          
class UniversityOfVictoriaParser < CourseParser
    def start
      parse(get("http://web.uvic.ca/calendar2006/CoIn/CBSuA.html")).search("a[@class='CTL']").each do |subject|

        course_doc = parse(get("http://web.uvic.ca/calendar2006/#{subject.attributes['href']}"))

        s_code = course_doc.at("h1[@class='topLine']").inner_html.sub(/.*(\(.{2,4}\)).*/,'\1').gsub(/[\(\)]/,'')
        s_name = course_doc.at("h1[@class='topLine']").inner_html.sub(/\(.*\)/,'').sub(/Courses/,'')

        xsubject = get_subject(s_code,s_name)

        puts s_code

        course_doc.search("ul[@class='CDTL'] > li > a").each do |course|

          info = parse(get("http://web.uvic.ca/calendar2006/#{course.attributes['href']}")).at("div[@id='CDpage']") rescue info = nil

          if info != nil then 

            c_number = info.at("h1").inner_html.sub(/#{s_code} (.*)/,'\1') rescue c_number = nil
  
            c_name = info.at("h2").inner_html rescue c_name = nil
  
            c_credits = info.at("h3").inner_html rescue c_credits = nil
            
            if c_credits != nil then 
              endvalue = (c_credits.index(',')-1) rescue endvalue = c_credits.length
              c_credits = c_credits.slice(0..endvalue)
            end
  
            c_description = info.search("p")[0].inner_html rescue nil
            if c_description.index("<b>") then
              c_description = nil
            end
            
            if info.at("div[@class='SC']") != nil then
              c_description = nil
            end

            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            
          else
            #p course.attributes['href']
          end

        end

      end
    end
end
