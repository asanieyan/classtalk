Info = {
    :name=>"University of New Brunswick",
    :nid=>"16778431",
    :city=>"fredericton",
    :region=>"new brunswick",    
    :country=>"canada",
    :semesters=>[
    ["Fall Term","9/6"],
    ["Winter Term","1/7"],
    ["Spring Term","5/1"],
    ["Summer Term","7/2"]
    ]
}          
class UniversityOfNewBrunswickParser < CourseParser
    def start
    

    
      ["4&title=Saint%20John%20Course%20Descriptions","1&title=Fredericton%20Course%20Descriptions"].each do |address_component|

        list_page = parse(get("http://eservices.unb.ca/calendar/undergraduate/index.cgi?tables=coursesSubLevel1&uniq=#{address_component}"))

        list_page.search("a").each do |subject_link|
          if subject_link.attributes['href'] =~ /display\.cgi/ && subject_link.inner_html !~ /Standard Course Abbreviations/ then
            
            courses_doc = parse(get("http://eservices.unb.ca/calendar/undergraduate/#{subject_link.attributes['href']}"))
            s_code = courses_doc.at("h2 > b").inner_html
            s_name = courses_doc.at("b > h3").inner_html
            xsubject = get_subject(s_code, s_name)

            puts s_code
            
            rows = courses_doc.search("table[@width='90%']")[3].search("tr")

            (0...(rows.length/2)).each do

              first = rows.shift
              maintags = first.search("td > b")
              c_number = maintags[0].inner_html.sub(/#{s_code} (\d+)/,'\1')
              c_name = maintags[1].inner_html.sub(/<.*>(.*)<\/.*>/,'\1')
              c_credits = maintags[2].inner_html.sub(/(\d+) ch.*/,'\1')
              second = rows.shift
              c_description = second.at("td").inner_html.gsub(/<br \/>/,"")

              course = xsubject.get_course(c_number,c_name,c_description,c_credits)

            end
            

          end
        end

      end


    end
end
