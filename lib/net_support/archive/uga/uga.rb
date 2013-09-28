Info = {
    :name=>"UGA",
    :nid=>"16777266",
    :city=>"athens",
    :region=>"georgia",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/15","12/25"],
      ["Spring","1/1","5/9"],
      ["May Session","5/12","6/5"],
      ["Summer Ext","5/13","6/30"],
      ["Summer Thru","6/5","7/31"],
      ["Summer Short 1","6/5","7/2"],
      ["Summer Short 2","7/3","8/1"]
    ],:paths=>[
      ["Fall","Spring","May Session"],
      ["Fall","Spring","Summer Ext"],
      ["Fall","Spring","Summer Thru"],      
      ["Fall","Spring","Summer Short 1","Summer Short 2"]         
    ]
}          
class UgaParser < CourseParser
    def start
      links = []
      doc_at("http://bulletin.uga.edu/bulletin/courses/discipline_listing.html").search("tr").each do|tr|
        next if tr.search("td").size != 2
        next if tr.search("td")[0].at("a") == nil
        next if tr.search("td")[1].inner_html.include?("-")        
        s_link = tr.search("td")[0].at("a")
        s_name = s_link.inner_html        
        s_code = tr.search("td")[1].inner_html        
        subject = get_subject(s_code,s_name)
        links << "http://bulletin.uga.edu/bulletin/courses/#{s_link['href']}"        
      end
#      links = ["http://bulletin.uga.edu/bulletin/courses/descript/indo.html"]
      i = 0
      links.each do |link|
        body = doc_at(link).at("body")
        courses = body.inner_html.split("<hr />")
        courses.each do |course|
            begin
              course = parse(course)
              next unless course.search("b").size > 0
              cnum_tag = course.search("b")[0]
              cname_tag = course.search("b")[1]
              cc = cname_tag.next_node.text? ? cname_tag.next_node.to_s : 0 
              s_code,cnum = cnum_tag.inner_html.split(" ",2)
              s_code.gsub!(/\(.*?\)/,'')
              cnum.delete!(".")
              cname = cname_tag.inner_html
              course.search("b").remove
              cdesc = strip_tags(course.inner_html)
              subject = find_subject_by_code(s_code)
              subject.get_course(cnum,cname,cdesc,cc)            
            rescue Exception=>e
                puts e
                fail unless confirm("cont.")
            end
        end
      end      
    end
end
