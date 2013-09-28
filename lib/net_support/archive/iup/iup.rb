Info = {
    :name=>"IUP",
    :nid=>"16777448",
    :city=>"indiana",
    :region=>"pennsylvania",    
    :country=>"united states",
    :semesters=>[
    
      ["Fall","8/27", "12/25"],
      ["Spring","1/10", "5/10"],
      ["Early Summer","5/15", "6/2"],
      ["Summer I","6/4", "7/6"], 
      ["Summer II","7/9", "8/9"],  

    ]
}          
class IupParser < CourseParser
    def start
      doc_at("http://www.iup.edu/registrar/catalog/course/index.shtm").search("a").each do |a|
#        puts a['href']        
        next unless a['href'] =~ /^\w+\.shtm/
        a['href'] = a['href'].gsub(/#.*$/,'')
        link = "http://www.iup.edu/registrar/catalog/course/#{a['href']}"
#        link = "http://www.iup.edu/registrar/catalog/course/comm.shtm#COMM%20493%20Internship"
        puts link        
        doc = doc_at(link)
        title = normalize(doc.search('div[@style*="border-bottom-style: solid;"]')[0].inner_text)
        sname = title.slice(/[^(]+/)
        title.slice!(/#{sname}/)
        scode = title.scan(/\([A-Z]+\)/).last
        scode.delete!(")(")
        get_subject(scode,sname)
        doc.search('a').each do |course|
            next unless course['name']            
            title = normalize(course['name'])
            next unless title =~ /^[A-Z][A-Z]+ /
            title = normalize(course.parent.inner_text)
            if title =~ /\d+, \d+/
                next
            end
             cc_p = course.parent
             while cc_p.pathname != "p" do 
                cc_p = cc_p.parent
             end
             cc_p = cc_p.next_sibling 
#             puts cc_p.pathname if cc_p.pathname != "p"             
#             next
             if cc_p.pathname == "span"
                cc_p = cc_p.at("p")
             end
             desc_p = cc_p.next_sibling
             if desc_p.at("b")
                desc_p = desc_p.next_sibling
             end                        
             cc = (cc_p.inner_text || "").slice(/\d+cr/)
             puts "\n"
             scode,cnum,cname = title.split(" ",3)
             subject = get_subject(scode)
             cc = cc.delete("cr") if cc
             cdesc = normalize(desc_p.inner_text)
             subject.get_course(cnum,cname,cdesc,cc)             
#            puts title
#            puts course.parent.parent.next_sibling
        end
#        puts normalize(title.inner_text)
      
      end
    end
end
