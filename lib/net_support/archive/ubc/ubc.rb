Info = {
    :name=>"UBC",
    :nid=>"16777427",
    :city=>"vancouver",
    :region=>"british columbia",    
    :country=>"canada",
    :semesters=>[
      ["Winter - Term 1","9/1"],
      ["Winter - Term 2","1/1"],
      ["Summer - Term1","5/1"],
      ["Summer - Term2","7/1"]
    ]
}          
class UbcParser < CourseParser
  def start
     parse(get('subjects.html')).search("tbody tr").each do |tr|        
        td1,td2,td3 =  tr.search("td")
        link = td1.at("a")['href']
        s_code = link.match(/\w+$/).to_s
        link = "http://www.students.ubc.ca/calendar/#{link}"
        subject = get_subject(s_code,td2.inner_html)
        html = get(link).read.gsub(/\s+/,' ').match(/<dl class="double">.*<\/dl>/).to_s
        parse(html).search("dl dt").each do |dt|
            c_name = dt.at("b").inner_html
            c_num  = dt.at("a")['name']
            c_credit = dt.inner_text.match(/\((.*?)\)/)[1]
            c_desc = dt.next_sibling.inner_html

            subject.get_course(c_num,c_name,c_credit,c_desc)
            p "#{s_code}-#{c_num} doesn't have desc: #{c_desc}" if c_desc.to_s == ""
        end
 #       p "#{s_code} doesn't have any courses" if subject.courses.size > 0        
     end
  end

end