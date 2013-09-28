Info = {
    :name=>"Thompson Rivers",
    :nid=>"16778490",
    :city=>"kamloops",
    :region=>"british columbia",    
    :country=>"canada",
    :semesters=>[
        ["Fall","9/4", "12/15"],
        ["Winter","1/8", "4/28"],
        ["Summer","5/7", "8/16"] 
    ]
}          
class ThompsonRiversParser < CourseParser
    def start
        ('A'..'Z').to_a.each do |l|                    
          ["http://www.tru.ca/admreg/course_schedules/fall.html?page=FA_Schedule_#{l}",
           "http://www.tru.ca/admreg/course_schedules/summer.html?page=SU_Schedule_#{l}",
           "http://www.tru.ca/admreg/course_schedules/winter.html?page=WI_Schedule_#{l}"].each do |link|
                doc = doc_at(link)
                snames = doc.search("h2")
                snames.shift
                snames.each do |h|
                    next_node = h.next_sibling
                    sname = normalize(h.inner_text)
                    while next_node && next_node.pathname != "h2"
                        if next_node.pathname == "h3"
                          scode,cnum,cname = normalize(next_node.inner_text).split(" ",3)
                          get_subject(scode,sname).get_course(cnum,cname,"","")
                        end
                        next_node = next_node.next_sibling 
                    end
                end
          end
        end
    end
end
