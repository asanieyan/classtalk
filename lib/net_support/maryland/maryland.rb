Info = {
    :name=>"Maryland",
    :nid=>"16777274",
    :city=>"college park",
    :region=>"maryland",    
    :country=>"united states",
    :semesters=>[
    ["Fall","8/29"],
    ["Winter","1/2"],
    ["Spring","1/28"],
    ["Summer","6/2"]
    ]
}          
class MarylandParser < CourseParser
    def start

      parse(get("http://www.umd.edu/catalog/index.cfm/show/content.chapter/c/50")).search("a[@class='ctloglink']").each do |subject|
        if subject.attributes['href'] != "#top" then

          s_code, s_name = subject.inner_html.split(" - ")
          xsubject = get_subject(s_code, s_name)

          parse(get("http://www.umd.edu#{subject.attributes['href']}")).search("p[@class='searchresults_subblock']").each do |course|
            c_data = course.at("strong").inner_html

            c_number = c_data.sub(/\w+? (\d+?H?) .*/,'\1')
            c_name = c_data.sub(/\w+? \d+? (.*)\(.*\)$/,'\1')
            c_credits = c_data.sub(/.*\((\d+-)?(\d+?)\)$/,'\2')

            c_description = course.inner_html.sub(/<strong>.*?<\/strong>(.*)/,'\1')

            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            puts s_code + " " + c_number + " " + c_name + " " + c_credits
          end
        end
      end
      
    end
end
