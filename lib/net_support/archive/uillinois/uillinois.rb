Info = {
    :name=>"UIllinois",
    :nid=>"16777236",
    :city=>"champaign",
    :region=>"illinois",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/16"],
      ["Spring","1/1"],
      ["Summer Term1","5/12"],
      ["Summer Term2","6/12"]
    ]
}          
class UillinoisParser < CourseParser
    def start
      doc_at("http://courses.uiuc.edu/cis/catalog/urbana/2007/Fall/").search("div.course_nos").each do |div|
          s_code = div.inner_html
          s_name = div.next_sibling.at("a").inner_html
          subject = get_subject(s_code,s_name)
          href = div.next_sibling.at("a")['href']          
          courses_url = "http://courses.uiuc.edu/cis/catalog/urbana/2007/Fall/#{href}"
          doc = doc_at(courses_url)
          doc.search("div.course_nos").each do |div2|
              cnum = div2.inner_html.gsub(/#{subject.code}/,'')
              link = div2.next_sibling.at("a")
              cname = link.inner_html
              course_url = "http://courses.uiuc.edu/cis/catalog/urbana/2007/Fall/#{subject.code}" + "/" + link['href']
              desc = doc_at(course_url).at("p")
              cc = desc.at("strong").next_node
              c_desc = desc.inner_html
              subject.get_course(cnum,cname,c_desc,cc)
          end
      end
    end
end
