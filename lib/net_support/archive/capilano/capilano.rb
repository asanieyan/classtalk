Info = {
    :name=>"Capilano",
    :nid=>"16780269",
    :city=>"vancouver",
    :region=>"british columbia",    
    :country=>"canada",
    :semesters=>[
      ["Fall","9/1"],
      ["Spring","1/1"],
      ["Summer Session I","5/1"],
      ["Summer Session II","7/1"]
    ]
}          
class CapilanoParser < CourseParser
    def start
       parse(get("http://www.capcollege.bc.ca/future/calendar/current/courses.html")).at("table.subject-index").at("tbody").search("tr").each do |tr|
          s_code = tr.search("td")[0].at("a").inner_html
          link = "http://www.capcollege.bc.ca" + tr.search("td")[0].at("a")['href']
          s_name = tr.search("td")[1].at("a").inner_html          
          subject = get_subject(s_code,s_name)          

          parse(get(link)).search("div.informaltable").each do |tbody|
             c_number = tbody.at(".course").inner_html.sub(/#{s_code} (.*)/,'\1') rescue nil
             c_name = tbody.at(".name").inner_html rescue nil
             c_credits = tbody.at(".credits").inner_html rescue nil
             c_desc = tbody.at(".description").inner_html rescue nil
             course = subject.get_course(c_number,c_name,c_desc,c_credits)
          end 
          p "there are not any courses for #{s_name}" if subject.courses.size == 0          

       end
    end
end
